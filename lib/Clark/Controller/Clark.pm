package Clark::Controller::Clark;

use strict;
use warnings;
use v5.36;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub _try_login {
    my ( $self, $user, $pass ) = @_;
    return $self->user_repository->by_name_and_pass( $user, $pass );
}

sub _can_attempt_login {
    my $self = shift;

    my $last_login_attempt = $self->session('last_login_attempt') || time;

    if ( time - $last_login_attempt >= 60000 ) {
        $self->session( login_attempts => 0 );
        return 1;
    }

    # Can attempt to login if they have less than 3 attempts and have waited at least a minute.
    return not( ( ( $self->session('login_attempts') || 0 ) >= 3 )
        && ( ( $last_login_attempt - time ) <= 6000 ) );
}

sub index ($self) {
    return $self->redirect_to('/dashboard') if $self->session('user');
    return $self->render;
}

sub login ($self) {
    $self->session( login_attempts     => ( $self->session('login_attempts') || 0 ) + 1 );
    $self->session( last_login_attempt => localtime );

    my $user = $self->req->param('name');

    if ( not( $self->_can_attempt_login ) ) {
        $self->app->log->info("Login attempt from user $user, failed due to too many attempts");
        $self->flash( message => 'You\'ve tried to login too many times recently, try again later' );
        return $self->render( status => 400, template => 'clark/index' );
    }

    my $pass = $self->req->param('password');

    if (   $user
        && $pass
        && ( my $user_model = $self->_try_login( $user, $pass ) ) )
    {
        $self->app->log->info("User $user logged in successfully");
        $self->session( user => $user_model->id );
        $self->redirect_to('/dashboard');
    }
    else {
        $self->app->log->info("Invalid login attempt for user: $user");
        $self->flash( message => 'Invalid Login' );
        $self->render( status => 404, template => 'clark/index' );
    }
}

sub logout ($self) {
    if ( my $user = $self->session('user') ) {
        $self->session( user => undef );
    }

    $self->redirect_to('/');
}

1;
