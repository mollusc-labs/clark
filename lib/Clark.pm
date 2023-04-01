package Clark;

use strict;
use warnings;
use experimental;
use v5.36;

use Mojo::Base 'Mojolicious', -signatures;
use Mojo::Log;
use Mojolicious::Validator::Validation;
use Carp q<croak>;
use Bread::Board;
use Clark::Util::Crypt;

our $VERSION = '0.1';

# Generate service depdencencies with Bread::Board
my $c = container 'Clark' => as {
    container 'Database' => as {
        if ( $ENV{'CLARK_PRODUCTION'} ) {
            service 'dsn' => "DBI:mysql:database=clark;host=clark_database";
        }
        else {
            service 'dsn' => "DBI:mysql:database=clark;host=127.0.0.1";
        }
        service 'username' => 'root';
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
    $self->helper( user_repository => sub { return $dbh->resultset('User') } );
    $self->helper( log_repository  => sub { return $dbh->resultset('Log') } );

    state $known_errors = {
        400 => { err => 400, msg => 'Bad Request' },
        503 => { err => 503, msg => 'Servince Unavailable' }
    };

    $self->hook(
        before_render => sub {
            my $c   = shift;
            my $err = $c->stash('err');

            return unless $err;

            if ( $known_errors->{$err} ) {
                return $c->render( status => $err, json => $known_errors->{$err} );
            }
            else {
                return $c->render( status => 503, json => $known_errors->{503} );
            }
        }
    );

    # Session validity and keeping track of user
    $self->hook(
        around_dispatch => sub {
            my $next = shift;
            my $c    = shift;
            $c->session( ip => $c->tx->original_remote_address ) unless $c->session('ip');
            if ( $c->session('ip') ne $c->tx->original_remote_address ) {
                $c->session( expires => 1 );
            }
            else {
                if ( my $uid = $c->session('user') ) {
                    my %user = $dbh->resultset('User')->find( { id => $uid } )->get_columns;
                    delete %user{'password'};
                    $c->stash( user => \%user );
                }
            }

            $next->();
        }
    );

    # Make sure there's always at least one user.
    unless ( scalar $self->user_repository->search->all ) {
        my $user = {
            name     => $ENV{'CLARK_USER'} || 'clark',
            password => Clark::Util::Crypt->hash( $ENV{'CLARK_PASS'} || 'clark' ),
            is_admin => 1
        };

        $self->user_repository->new_result($user)->insert;
    }

    my $log = Mojo::Log->new( level => 'trace' );

    my $router      = $self->routes->namespaces( ['Clark::Controller'] );
    my $csrf_router = $self->routes->under(
        '/' => sub ($c) {
            return 1 if $c->req->method ne 'POST';

            my $v = $c->validation;
            if ( $v->csrf_protect->has_error('csrf_token') ) {
                $c->render( json => { err => 400, msg => 'Invalid csrf token' }, status => 400 );
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

    if ( $ENV{'CLARK_PRODUCTION'} ) {
        push @{ $self->static->paths }, 'frontend/dist';
    }

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

    # Clark routes
    $router->any('/')->to('clark#index')->name('clark_index');
    $csrf_router->post('/login')->to('clark#login')->name('clark_login');
    $router->any('/logout')->to('clark#logout')->name('clark_logout');

    # User routes
    $authorized_router->post('/change-password')->to('clark#change_password')->name('clark_change_password');
    $authorized_router->post('/update-user')->to('clark#update_user')->name('clark_update_user');

    # Dashboard routes
    $authorized_router->get('/dashboard')->to('dashboard#index')->name('dashboard_index');

    # Api routes
    ## Log routes
    $app_authorized_router->post('/api/logs')->to('log#create')->name('create_log');
    $app_authorized_router->get('/api/logs')->to('log#find')->name('find_log');
    $app_authorized_router->get('/api/logs/latest')->to('log#latest')->name('latest_log');
    $app_authorized_router->get('/api/logs/today')->to('log#today')->name('today_log');

    unless ( $ENV{'CLARK_PRODUCTION'} ) {
        $router->get('/api/test/logs')->to('log#find')->name('TEST_DELETE_ME');
        $router->post('/api/test/logs')->to('log#create')->name('DELETE_ME_TOO');
        $router->get('/api/test/logs/latest')->to('log#latest')->name('DELETE_ME_THREE');
        $router->get('/api/test/logs/today')->to('log#today')->name('DELETE_MEEEEE');
    }

    $self->app->log($log);
}

1;
