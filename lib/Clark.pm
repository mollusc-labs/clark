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
use Crypt::JWT qw(decode_jwt);

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
                return Clark::Schema->connect(
                    $s->param('dsn'),
                    $s->param('username'),
                    $s->param('password')
                ) || croak 'Could not connect to database.';
            },
            dependencies => [ 'dsn', 'username', 'password' ]
        );
    };

    container 'Validator' => as {
        service 'dashboard' => (
            lifecycle => 'Singleton',
            block     => sub {
                require Clark::Validator::Dashboard;
                return Clark::Validator::Dashboard->new;
            },
            dependencies => []
        );

        service 'log' => (
            lifecycle => 'Singleton',
            block     => sub {
                require Clark::Validator::Log;
                return Clark::Validator::Log->new;
            },
            dependencies => []
        );

        service 'key' => (
            lifecycle => 'Singleton',
            block     => sub {
                require Clark::Validator::Key;
                return Clark::Validator::Key->new;
            },
            dependencies => []
        );
    };
};

no Bread::Board;

my $api_key = $ENV{'CLARK_API_KEY'}
    || croak
    'You need to set the "CLARK_API_KEY" environment variable. See QUICKSTART to get started.';

sub startup ($self) {

    $self->app->secrets( [$api_key] );

    # Database boilerplate
    my $dbh = $c->resolve( service => 'Database/dbh' );
    $self->helper( user_repository => sub { return $dbh->resultset('User') } );
    $self->helper( log_repository  => sub { return $dbh->resultset('Log') } );
    $self->helper( key_repository  => sub { return $dbh->resultset('Key') } );
    $self->helper(
        dashboard_repository => sub { return $dbh->resultset('Dashboard') } );
    $self->helper(
        datetime_parser => sub { return $dbh->storage->datetime_parser } );

    # Other dependencies
    $self->helper( dashboard_validator =>
            sub { return $c->resolve( service => 'Validator/dashboard' ) } );
    $self->helper( log_validator =>
            sub { return $c->resolve( service => 'Validator/log' ) } );
    $self->helper( key_validator =>
            sub { return $c->resolve( service => 'Validator/key' ) } );

    state $known_errors = {
        400 => { err => 400, msg => 'Bad Request' },
        503 => { err => 503, msg => 'Service Unavailable' }
    };

    $self->hook(
        before_render => sub {
            my $c   = shift;
            my $err = $c->stash('err');

            return unless $err;

            if ( $known_errors->{$err} ) {
                return $c->render(
                    status => $err,
                    json   => $known_errors->{$err}
                );
            }
            else {
                return $c->render(
                    status => 503,
                    json   => $known_errors->{503}
                );
            }
        }
    );

    # Make sure there's always at least one user.
    unless ( scalar $self->user_repository->search->all ) {
        croak 'Your clark user is not set, please read QUICKSTART.md'
            unless $ENV{'CLARK_USER'};
        croak 'Your clark password is not set, please read QUICKSTART.md'
            unless $ENV{'CLARK_PASS'};
        my %user = (
            name     => $ENV{'CLARK_USER'},
            password => Clark::Util::Crypt->hash( $ENV{'CLARK_PASS'} ),
            is_admin => 1
        );

        $self->user_repository->create( \%user )->insert;
    }

    my $log = Mojo::Log->new( level => 'trace' );

    my $router      = $self->routes->namespaces( ['Clark::Controller'] );
    my $csrf_router = $self->routes->under(
        '/' => sub ($c) {
            return 1 if $c->req->method ne 'POST';

            my $v = $c->validation;
            if ( $v->csrf_protect->has_error('csrf_token') ) {
                $c->render(
                    json   => { err => 400, msg => 'Invalid csrf token' },
                    status => 400
                );
                return undef;
            }
            return 1;
        }
    );

    # For routes only accessible by a session token
    my $only_authorized_router = $router->under(
        '/' => sub ($c) {

           # Web sockets dont carry sessions, they've already been authenticated
            return 1 if $c->tx->is_websocket;

            # For SPA requests
            if ( $c->session('user') ) {
                if ( not( $c->tx->is_websocket )
                    && $c->session('ip') ne $c->tx->original_remote_address )
                {
                    $c->session( expires => 1 );
                    $c->redirect_to('/');
                    return undef;
                }

                my $uid = $c->session('user');
                if ( my $user
                    = $dbh->resultset('User')->find( { id => $uid } ) )
                {
                    my %user = $user->get_columns;
                    delete %user{'password'};
                    $c->stash( user    => \%user );
                    $c->stash( api_key => $api_key );
                }
                else {
                    $c->session( expires => 1 );
                    $c->redirect_to('/');
                    return undef;
                }

                return 1;
            }

            return undef;
        }
    );

    # For routes that require an API-key OR session token
    my $authorized_router = $router->under(
        '/' => sub ($c) {

           # Web sockets dont carry sessions, they've already been authenticated
            return 1 if $c->tx->is_websocket;

            # For SPA requests
            if ( $c->session('user') ) {
                if ( not( $c->tx->is_websocket )
                    && $c->session('ip') ne $c->tx->original_remote_address )
                {
                    $c->session( expires => 1 );
                    $c->redirect_to('/');
                    return undef;
                }

                my $uid = $c->session('user');
                if (my $user = $dbh->resultset('User')->find(
                        { id      => $uid },
                        { columns => [qw/name is_admin last_login/] }
                    )
                    )
                {
                    my %user = $user->get_columns;
                    $c->stash( user    => \%user );
                    $c->stash( api_key => $api_key );
                }
                else {
                    $c->session( expires => 1 );
                    $c->redirect_to('/');
                    return undef;
                }

                return 1;
            }

            # Header should be in form: 'Bearer <API-JWT>'
            my $req_api_key
                = ( split /\s/, $c->req->headers->to_hash->{'X-CLARK'} || '' )
                [-1];

            my $header;
            my $payload;
            eval {
                ( $header, $payload ) = decode_jwt(
                    token => $req_api_key,
                    key   => $ENV{'CLARK_API_KEY'}
                );
            };
            unless ( $req_api_key && not($@) ) {
                $c->render(
                    json   => { err => 401, msg => 'Unauthorized' },
                    status => 401
                );
                return undef;
            }

            return defined $c->key_repository->by_key($req_api_key);
        }
    );

    # For routest that require administrator access
    my $admin_authorized_router = $authorized_router->under(
        '/' => sub ($c) {
            unless ( $c->session('is_admin') ) {
                $c->render(
                    status => 401,
                    json   => { err => 401, msg => 'Unauthorized' }
                );
                return undef;
            }
            return 1;
        }
    );

    # Clark routes
    $router->get('/')->to('clark#index')->name('clark_index');
    $router->get('/login')->to('clark#login_index')->name('clark_login_index');
    $csrf_router->post('/login')->to('clark#login')->name('clark_login');
    $router->any('/logout')->to('clark#logout')->name('clark_logout');

    # User routes
    $only_authorized_router->post('/change-password')
        ->to('clark#change_password')->name('clark_change_password');
    $only_authorized_router->post('/update-user')->to('clark#update_user')
        ->name('clark_update_user');

    # Dashboard routes
    if ( $ENV{'CLARK_PRODUCTION'} ) {
        $only_authorized_router->get('/dashboard')->to('dashboard#index')
            ->name('dashboard_index');
    }
    else {
        $only_authorized_router->get('/dashboard')->to('dashboard#dev')
            ->name('dashboard_dev');
    }

    # Api routes
    ## Identification routes
    $only_authorized_router->get('/api/users/identify')->to('user#identify')
        ->name('identify_user');
    ## Log routes
    $authorized_router->websocket('/ws/logs/latest')->to('log#latest_ws')
        ->name('ws_latest_log');
    $authorized_router->post('/api/logs')->to('log#create')->name('create_log');
    $authorized_router->get('/api/logs')->to('log#find')->name('find_log');
    $authorized_router->get('/api/logs/latest')->to('log#latest')
        ->name('latest_log');
    $authorized_router->get('/api/logs/today')->to('log#today')
        ->name('today_log');
    $authorized_router->get('/api/logs/count')->to('log#count')
        ->name('count_log');
    $authorized_router->get('/api/logs/services')->to('log#service_names')
        ->name('service_names_log');
    $authorized_router->get('/api/logs/hosts')->to('log#hostnames')
        ->name('hostnames_log');
    ## Dashboard routes
    $authorized_router->get('/api/dashboards')->to('dashboard#find')
        ->name('find_dashboard');
    $authorized_router->post('/api/dashboards')->to('dashboard#create')
        ->name('create_dashboard');
    $authorized_router->put('/api/dashboards/:id')->to('dashboard#update')
        ->name('update_dashboard');
    $authorized_router->delete('/api/dashboards/:id')->to('dashboard#delete')
        ->name('delete_dashboard');
    ## API Key routes
    $admin_authorized_router->get('/api/keys')->to('key#find')
        ->name('find_key');
    $admin_authorized_router->post('/api/keys')->to('key#create')
        ->name('create_key');
    $admin_authorized_router->delete('/api/keys/:value')->to('key#delete')
        ->name('delete_key');

    $self->app->log($log);
}

1;