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

    if ( not( $self->_can_attempt_login ) ) {
        $self->flash( message => 'You\'ve tried to login too many times recently. Try again later.' );
        return $self->render( status => 404, template => 'clark/index' );
    }

    my $user = $self->req->param('name');
    my $pass = $self->req->param('password');

    if (   $user
        && $pass
        && ( my $user_model = $self->_try_login( $user, $pass ) ) )
    {
        $self->session( user => $user_model->id );
        $self->redirect_to('/dashboard');
    }
    else {
        $self->app->log->info("Invalid login attempt for user: $user");
        $self->flash( message => 'Invalid Login' );
        $self->render('index');
    }
}

sub logout ($self) {
    if ( my $user = $self->session('user') ) {
        $self->session( user => undef );
    }

    $self->redirect_to('/');
}

1;
