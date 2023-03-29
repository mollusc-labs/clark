package Clark::Controller::Log;

use strict;
use warnings;
use experimental qw(signatures);
use Mojo::Util   qw(secure_compare);
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub find ($self) {
    my $logs = $self->log_repository->find( $self->req->params->to_hash );
    return $self->render( json => $logs );
}

sub create ($self) {
    unless ( $self->req->json ) {
        $self->res->code(400);
        return $self->render( text => '' );
    }

    $self->app->log->debug( Dumper $self->req->json );
    $self->res->code(201);
    $self->render( text => '' );
}

1;
