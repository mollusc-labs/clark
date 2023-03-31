package Clark::Controller::Log;

use strict;
use warnings;
use experimental qw(signatures);
use Mojo::Util   qw(secure_compare);
use Mojo::Base 'Mojolicious::Controller', -signatures;
use Clark::Util::Crypt;

sub update_password {
    my $self         = shift;
    my $user         = $self->user_repository->find( { id => $self->session('user') } );
    my $old_password = $self->req->json->{'old_password'};
    my $new_password = $self->req->json->{'new_password'};

    if ( $user->password ne Clark::Util::Crypt->hash($old_password) ) {
        return $self->render( status => 400, json => { err => 400, msg => 'Old password is incorrect.' } );
    }

    $user->update( password => Clark::Util::Crypt->hash($new_password) );

    return $self->render( status => 204 );
}

sub update_user {
    my $self     = shift;
    my $user     = $self->user_repository->find( { id => $self->session('user') } );
    my $password = $self->req->json->{'password'};
    my $username = $self->req->json->{'username'};

    if ( $user->password ne Clark::Util::Crypt->hash($password) ) {
        return $self->render( status => 400, json => { err => 400, msg => 'Invalid password.' } );
    }

    return $self->render( status => 204 );
}