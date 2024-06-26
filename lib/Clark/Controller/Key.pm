package Clark::Controller::Key;

use strict;
use warnings;

use Crypt::JWT qw(encode_jwt);
use Carp       qw(croak);
use Clark::Util::UUID;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub create {
    my $self = shift;
    my $uid  = $self->session('user');

    my @errors = @{ $self->key_validator->validate( $self->req->json || {} ) };
    if ( scalar @errors ) {
        return $self->render(
            json   => { err => 400, msg => \@errors },
            status => 400
        );
    }

    my $id      = Clark::Util::UUID->new;
    my $matcher = $self->req->json->{'matcher'};
    my $key     = encode_jwt(
        payload => { id => $id, matcher => $matcher },
        alg     => 'HS256',
        key     => $ENV{'CLARK_API_KEY'}
    ) || croak 'Your CLARK_API_KEY is not set';

    my $obj = {
        $self->key_repository->create(
            {   id         => $id,
                value      => $key,
                matcher    => $matcher,
                created_by => $uid
            },
            { columns => [qw/value matcher/] }
        )->get_inflated_columns
    };

    delete $obj->{'id'};
    delete $obj->{'created_by'};

    $self->render( status => 201, json => $obj );
}

sub find {
    my $self = shift;
    my $keys = $self->key_repository->active->search( {}, { columns => [qw/id value matcher/] } );
    return $self->render( json => Clark::Util::Inflate->many( $keys->all ) );
}

sub delete {
    my $self = shift;
    my $id   = $self->stash('id');
    my $key  = $self->key_repository->find( { id => $id } );
    return $self->render(
        status => 404,
        json   => { err => 404, msg => 'Not found' }
    ) unless $key;
    $key->delete;
    $self->rendered(204);
}

1;

