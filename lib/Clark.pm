package Clark;

use strict;
use warnings;
use experimental;

use Mojo::Base 'Mojolicious', -signatures;
use Mojo::Log;
use Mojolicious::Validator::Validation;
use Carp q<croak>;
use Bread::Board;

our $VERSION = '0.1';

# Generate service depdencencies with Bread::Board
my $c = container 'Clark' => as {
    container 'Database' => as {
        if ( $ENV{'CLARK_PRODUCTION'} ) {
            service 'dsn' => "DBI:mysql:database='clark';host=clark_database";
        }
        else {
            service 'dsn' => "DBI:mysql:database='clark';host=127.0.0.1";
        }
        service 'username' => $ENV{MYSQL_USER};
        service 'password' => $ENV{MYSQL_PASS};

        service 'dbh' => (
            lifecycle => 'Singleton',
            block     => sub {
                require Clark::Schema;
                my $s = shift;
                return Clark::Schema->connect( $s->param('dsn'), $s->param('username'), $s->param('password') ) || croak 'Could not connect to database.';
            },
            dependencies => [ 'dsn', 'username', 'password' ]
        );
    };
};

no Bread::Board;

my $api_key = $ENV{'CLARK_API_KEY'};

sub startup ($self) {

    # Database boilerplate
    my $dbh = $c->resolve( service => 'Database/dbh' );
    $self->helper( user_repository => $dbh->resultset('User') );
    $self->helper( log_repository  => $dbh->resultset('Log') );

    my $log = Mojo::Log->new( level => 'trace' );

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
            my $req_api_key = split /\s/, $c->req->headers->to_hash->{'X-CLARK'};
            unless ($req_api_key) {
                $c->redirect_to('/');
                return undef;
            }
            return $req_api_key eq $api_key;
        }
    );

    $router->any('/')->to('clark#index')->name('clark_index');
    $router->post('/login')->to('clark#login')->name('clark_login');
    $router->any('/logout')->to('clark#logout')->name('clark_logout');

    $authorized_router->get('/dashboard')->to('dashboard#index')->name('dashboard');

    $app_authorized_router->post('/api/logs')->to('log#create')->name('create_log');
    $app_authorized_router->get('/api/logs')->to('log#find')->name('find_log');

    $router->get('/api/test/logs')->to('log#find')->name('TEST_DELETE_ME');

    $self->app->log($log);
}

1;
