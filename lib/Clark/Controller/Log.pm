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
    $self->app->log->debug($self->req->json);
    $self->res->code(201);
    $self->render(text => '');
}

1;
