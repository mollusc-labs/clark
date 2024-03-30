package Clark::Controller::Log;

use strict;
use warnings;

use Mojo::Util qw(secure_compare);
use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON qw(encode_json decode_json);
use Clark::Util::Inflate;
use DateTime;
use Data::UUID;
use Scalar::Util qw(looks_like_number);

sub _find {
    my $self   = shift;
    my $params = $self->req->params->to_hash;
    return $self->log_repository->by_params( %{$params} );
}

sub find {
    my $self = shift;
    return $self->render( json => Clark::Util::Inflate->many( $self->_find ) );
}

sub count {
    my $self  = shift;
    my $count = $self->_find->search( {}, { '+select' => [ { count => '*', -as => 'total' } ] } )->get_column('total');
    return $self->render( json => { count => $count } );
}

sub latest {
    my $self = shift;
    return $self->render(
        json => Clark::Util::Inflate->many( $self->log_repository->latest( $self->req->param('count') ) ) );
}

sub latest_ws {
    my $self = shift;
    Mojo::IOLoop->stream( $self->tx->connection )->timeout(1200);

    $self->on(
        message => sub {
            my ( $c, $msg ) = @_;
            my $req = decode_json $msg;
            unless ( $req->{'date'} ) {
                $self->app->log->info( 'Got bad body from web-socket: ' . $msg );
                $c->send( encode_json { err => 400, msg => 'Invalid json ' } );
                return;
            }

            my $date = DateTime->from_epoch( epoch => $req->{'date'} ) || return;
            $c->send(
                encode_json(
                    Clark::Util::Inflate->many( $self->log_repository->from_date( $date, DateTime->now, 100 )->all )
                )
            );
        }
    );
}

sub today {
    my $self = shift;
    return $self->render( json =>
            [ Clark::Util::Inflate->many( $self->log_repository->today( $self->req->param('service_name') )->all ) ] );
}

sub create {
    my $self = shift;
    my $json;
    eval { $json = $self->req->json }
        or return $self->render(
        json   => { err => 400, msg => 'Bad Request' },
        status => 400
        );

    my @errors = @{ $self->log_validator->validate($json) };
    if ( scalar @errors ) {
        return $self->render(
            json   => { err => 400, msg => \@errors },
            status => 400
        );
    }

    $json->{'hostname'}   = 'rest' unless $json->{'hostname'};
    $json->{'process_id'} = 'rest' unless $json->{'process_id'};

    $json->{'id'} = Data::UUID->new->create_str;

    # Test if API key matcher matches service name
    unless ( $json->{'service_name'} =~ $self->stash('api_key')->{'matcher'} ) {
        return $self->render(
            json   => { err => 401, msg => 'Service name not authorized by matcher' },
            status => 401
        );
    }

    my $log = { $self->log_repository->create($json)->get_inflated_columns };
    delete $log->{'id'};
    $self->app->log->info( 'Created log via REST with id: ' . $log->{'id'} );
    $self->render(
        status => 201,
        json   => $log
    );
}

sub service_names {
    my $self = shift;
    my @names
        = map { $_->get_column('service_name') }
        $self->log_repository->search( {}, { columns => [qw/service_name/], distinct => 1 } );
    return $self->render( json => \@names );
}

sub hostnames {
    my $self = shift;
    my @names
        = map { $_->get_column('hostname') }
        $self->log_repository->search( {}, { columns => [qw/hostname/], distinct => 1 } );
    return $self->render( json => \@names );
}

1;
