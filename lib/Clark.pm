package Clark;

use Mojo::Base 'Mojolicious', -signatures;
use Mojo::Log;
use Mojolicious::Validator::Validation;
use experimental qw(say);

my $api_key = $ENV{'CLARK_API_KEY'};

sub startup ($self) {
    my $log    = Mojo::Log->new( level => 'trace' );
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

    # For routes that require user authorization
    my $authorized_router = $router->under(
        '/' => sub ($c) {
            unless ( $c->session('user') ) {
                $c->redirect_to('/');
                return undef;
            }

            return 1;
        }
    );

    # For routes that require an API-key
    my $app_authorized_router = $router->under(
        '/' => sub ($c) {
            my $req_api_key = split /\s/, $c->headers->to_hash->{'X-CLARK'};
            return undef unless ($req_api_key);
            return $req_api_key eq $api_key;
        }
    );

    $router->any('/')->to('clark#index')->name('clark_index');
    $router->post('/login')->to('clark#login')->name('clark_login');
    $router->any('/logout')->to('clark#logout')->name('clark_logout');

    $authorized_router->get('/dashboard')->to('dashboard#index')->name('dashboard');

    $app_authorized_router->post('/api/logs')->to('log#create')->name('create_log');
    $app_authorized_router->get('/api/logs/:app_name')->to('log#find')->name('find_log');

    $self->app->log($log);
}

1;
