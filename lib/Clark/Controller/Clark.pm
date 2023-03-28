package Clark::Controller::Clark;

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller', -signatures;

sub _try_login {
    my ( $user, $pass ) = @_;
}

sub _can_attempt_login {
    my $self = shift;

    my $last_login_attempt = $self->session('last_login_attempt') || localtime;

    $self->session( login_attempts => 0 ) if ( $last_login_attempt - localtime >= 36000 );

    # Can attempt to login if they have less than 3 attempts and have waited at least a minute.
    return not( ( ( $self->session('login_attempts') || 0 ) >= 3 )
        && ( ( $last_login_attempt - localtime ) <= 6000 ) );
}

sub index ($self) {
    return $self->redirect_to('/dashboard') if $self->session('user');
    return $self->render;
}

sub login ($self) {
    if ( not( _can_attempt_login $self) ) {
        $self->flash( message => 'You\'ve tried to login too many times recently. Try again later.' );
        $self->render;
    }

    $self->session( login_attempts     => ( $self->session('login_attempts') || 0 ) + 1 );
    $self->session( last_login_attempt => localtime );

    my $user = $self->param('user');
    my $pass = $self->param('password');

    if ( my $user_model = _try_login $user, $pass ) {
        $self->session( user => $user_model );
        $self->redirect_to('/dashboard');
    }
    else {
        $self->app->log->info("Invalid login attempt for user: $user");
        $self->flash( message => 'Invalid Login' );
        $self->render;
    }
}

sub logout ($self) {
    if ( my $user = $self->session('user') ) {
        $self->session( user => undef );
    }

    $self->redirect_to('/');
}

1;
