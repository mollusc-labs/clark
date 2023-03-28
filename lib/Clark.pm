package Clark;

use Mojo::Base 'Mojolicious', -signatures;
use Mojolicious::Validator::Validation;
use experimental qw(say);

sub startup ($self) {
    my $router = $self->routes->under(
        '/' => sub ($c) {
            return 1 if $c->req->method ne 'POST';

            my $v = $c->validation;
            if ( $v->csrf_protect->has_error('csrf_token') ) {
                say 'error';
                $c->render( text => '', status => 400 );
                return undef;
            }
            return 1;
        }
    );

    my $authorized_router = $router->under(
        '/' => sub ($c) {
            return undef unless $c->session('user');
        }
    );

    $router->any('/')->to('clark#index')->name('index');
    $router->post('/login')->to('clark#login')->name('login');

    $authorized_router->get('/logs')->to('log#index')->name('logs');

    # TODO: This should be under an App Authorized router, that has a key for authorized apps
    $router->post('/logs')->to('log#log')->name('http_log');
}

1;
