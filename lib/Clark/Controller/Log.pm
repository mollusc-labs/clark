package Clark::Controller::Log;

use strict;
use warnings;
use experimental qw(signatures);
use Mojo::Util   qw(secure_compare);
use Mojo::Base 'Mojolicious::Controller', -signatures;
use Clark::Util::Inflate;

sub find {
    my $self = shift;
    my @logs = Clark::Util::Inflate->many( $self->log_repository->by_params( %{ $self->req->params->to_hash } ) );
    return $self->render( json => \@logs );
}

sub latest {
    my $self = shift;
    my @logs = Clark::Util::Inflate->many( $self->log_repository->latest( $self->req->param('count') ) );
    return $self->render( json => \@logs );
}

sub today {
    my $self = shift;
    my @logs = Clark::Util::Inflate->many( $self->log_repository->today( $self->req->param('service_name') ) );
    return $self->render( json => \@logs );
}

sub create {
    my $self = shift;
    my $log  = $self->log_repository->create( $self->req->json );
    my %json = $log->get_columns;
    $self->render( status => 201, json => \%json );
}

1;
