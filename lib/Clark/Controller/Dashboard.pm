package Clark::Controller::Dashboard;

use strict;
use warnings;
use experimental qw(say);
use Data::Dumper;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub index {
    my $self = shift;
    return $self->render;
}

1;
