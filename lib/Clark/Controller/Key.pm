package Clark::Controller::Key;

use strict;
use warnings;
use Crypt::JWT qw(encode_jwt);
use Mojo::Base 'Mojolicious::Controller', -signatures;

# TODO: Add validation here via validator
sub create {
    my $self    = shift;
    my $uid     = $self->session('user');
    my $matcher = $self->req->json->{'matcher'};
    my $key     = encode_jwt(
        payload => { user => $uid, matcher => $matcher },
        alg     => 'HS256',
        key     => $ENV{'CLARK_API_KEY'}
    );

    my %obj = $self->key_repository->create(
        {   value      => $key,
            matcher    => $matcher,
            created_by => $uid
        }
        )->get_columns
        || return $self->render( status => 400, json => { err => 400, msg => 'Bad request' } );
    delete $obj{'id'};

    $self->render( status => 201, json => %obj );
}

sub delete {
    my $self = shift;
    my $key  = $self->stash('api_key');
    eval { $self->key_repository->delete( { key => $key } ) };
    return $self->render( status => 404, json => { err => 404, msg => 'Not found' } ) if $@;
    $self->render( status => 204 );
}

1;