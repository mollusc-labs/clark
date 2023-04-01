package Clark::Controller::Clark;

use strict;
use warnings;
use v5.36;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use DateTime;

sub _try_login {
    my ( $self, $user, $pass ) = @_;
    return $self->user_repository->by_name_and_pass( $user, $pass );
}

sub _can_attempt_login {
    my $self = shift;

    my $last_login_attempt = $self->session('last_login_attempt') || time;
    my $login_attempts     = $self->session('login_attempts');

    if ( ( ( time - $last_login_attempt ) <= 60 ) && $login_attempts >= 3 ) {
        return 0;
    }

    return 1;
}

sub index ($self) {
    return $self->redirect_to('/dashboard') if $self->session('user');
    return $self->render;
}

sub login ($self) {
    $self->redirect_to('/dashboard') if ( $self->session('user') );

    $self->session( login_attempts => ( $self->session('login_attempts') || 0 ) + 1 );

    my $v = $self->validation;

    $v->required('name')->size( 1, 100 );
    $v->required('password')->size( 1, ~0 );
    return $self->stash( err => 400 ) unless $v->has_data && ( not $v->has_error );

    my $user = $self->req->param('name');
    my $pass = $self->req->param('password');

    if ( not( $self->_can_attempt_login ) ) {
        $self->session( last_login_attempt => time );
        $self->app->log->info("Login attempt for user $user failed due to too many attempts");
        $self->stash( message => 'You\'ve tried to login too many times recently, try again later' );
        return $self->render( status => 429, template => 'clark/index' );
    }

    $self->session( login_attempts => 1 ) if $self->session('login_attempts') >= 3;

    if ( my $user_model = $self->_try_login( $user, $pass ) ) {
        $self->app->log->info("User $user logged in successfully");
        $user_model->last_login( DateTime->now );
        $user_model->update;
        $self->session( user => $user_model->id );
        $self->redirect_to('/dashboard');
    }
    else {
        $self->session( last_login_attempt => time );
        $self->app->log->info("Invalid login attempt for user: $user");
        $self->stash( message => 'Invalid Login' );
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
