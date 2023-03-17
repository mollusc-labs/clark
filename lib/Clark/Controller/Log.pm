package Clark::Controller::Log;

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller', -signatures;
use experimental qw(say);

sub index ($self) {
    return $self->render;
}

sub log ($self) {
    my $log = $self->json;
    say $log;
    return $self->res->code(201);
}

1;
