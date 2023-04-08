package Clark::Controller::Log;

use strict;
use warnings;
use experimental qw(signatures);
use Mojo::Util   qw(secure_compare);
use Mojo::Base 'Mojolicious::Controller', -signatures;
use Mojo::JSON qw(encode_json decode_json);
use Clark::Util::Inflate;
use Data::Dumper;
use DateTime;

sub _find {
    my $self   = shift;
    my %params = %{ $self->req->params->to_hash };
    if (   $params{'from'}
        && $params{'to'} )
    {
        my $from = DateTime->from_epoch( epoch => $params{'from'} ) || DateTime->from_epoch( epoch => 0 );
        my $to   = DateTime->from_epoch( epoch => $params{'to'} )   || DateTime->now;
        delete $params{'from'};
        delete $params{'to'};
        return $self->log_repository->from_date( $from, $to )->by_params(%params);
    }
    else {
        delete $params{'to'};
        delete $params{'from'};
        return $self->log_repository->by_params(%params);
    }
}

sub find {
    my $self = shift;
    $self->app->log->info( Dumper $self->_find );
    my @logs = Clark::Util::Inflate->many( $self->_find );
    return $self->render( json => \@logs );
}

sub count {
    my $self  = shift;
    my $count = $self->_find->search( {}, { '+select' => [ { count => '*', -as => 'total' } ] } ) . get_column('total');
    return $self->render( json => { count => $count } );
}

sub latest {
    my $self = shift;
    my @logs = Clark::Util::Inflate->many( $self->log_repository->latest( $self->req->param('count') ) );
    return $self->render( json => \@logs );
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
            my @logs = Clark::Util::Inflate->many( $self->log_repository->from_date($date) );
            $c->send( encode_json( \@logs ) );
        }
    );
}

sub today {
    my $self = shift;
    my @logs = Clark::Util::Inflate->many( $self->log_repository->today( $self->req->param('service_name') ) );
    return $self->render( json => \@logs );
}

sub create {
    my $self    = shift;
    my %json_in = %{ $self->req->json };
    $json_in{'hostname'}   = 'REST';
    $json_in{'process_id'} = 'REST';
    my $log = $self->log_repository->create( \%json_in )
        || return $self->render( status => 400, json => { err => 400, msg => 'Invalid JSON for logging' } );
    my %json = $log->get_columns;
    delete $json{'id'};
    $self->render( status => 201, json => \%json );
}

1;
