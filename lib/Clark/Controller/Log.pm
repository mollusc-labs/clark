package Clark::Controller::Log;

use strict;
use warnings;
use experimental qw(say);

use Data::Dumper;

use Mojo::Base 'Mojolicious::Controller', -signatures;

sub index ($self) {
    return $self->render;
}

sub log ($self) {
    unless ($self->req->json) {
        $self->res->code(400);
        return $self->render(text => '');
    }
    
    $self->app->log->debug(Dumper $self->req->json);
    $self->res->code(201);
    $self->render(text => '');
}

1;
