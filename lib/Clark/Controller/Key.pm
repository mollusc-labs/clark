package Clark::Controller::Key;

use strict;
use warnings;
use Crypt::JWT qw(encode_jwt);
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub create {
    my $self    = shift;
    my $user    = $self->stash('user');
    my $uid     = $user->{'id'};
    my $matcher = $self->req->json->{'matcher'};
    my $key     = encode_jwt(
        payload => { user => $user->{'name'}, matcher => $matcher },
        alg     => 'HS256',
        key     => $ENV{'CLARK_API_KEY'}
    );

    my %obj = $self->key_repository->create(
        {   key        => $key,
            matcher    => $matcher,
            created_by => $uid
        }
        )->get_columns
        || return $self->render( status => 400, msg => 'Bad request' );
    delete $obj{'id'};

    $self->render( status => 201, json => %obj );
}

1;