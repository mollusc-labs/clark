package Clark::Controller::Clark;

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller', -signatures;

sub index ($self) {
    $self->stash(failed_login => 0);
    return $self->render;
}

sub login ($self) {
    $self->render(text => 'logged in');
}

1;
