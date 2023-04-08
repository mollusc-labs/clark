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

#| This is for the vue dev server
sub dev {
    my $self = shift;
    return $self->redirect_to('http://localhost:5173/dashboard');
}

sub create {
    my $self = shift;
    my $name = $self->req->json->{'name'} || 'Unnamed Dashboard';
}

1;
