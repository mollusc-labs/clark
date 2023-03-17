package Clark;

use Mojo::Base 'Mojolicious', -signatures;
use Mojolicious::Validator::Validation;
use experimental qw(say);

sub startup ($self) {
  my $router = $self->routes;

  my $validate_csrf = $self->routes->under('/' => sub ($c) {
        my $v = $c->validation;
        if ($v->csrf_protect->has_error('csrf_token')) {
            say 'error';
            $c->render(text => '', status => 403);
            return undef;
        }

        return 1;
    });

    $router->any('/')->to('clark#index')->name('index');
    $validate_csrf->post('/login')->to('clark#login')->name('login');

    $router->get('/logs')->to('logs#index')->name('logs');
    $validate_csrf->post('/logs')->to('logs#http_log')->name('http_log');
}

1;
