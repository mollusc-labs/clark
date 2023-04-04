package Clark::Controller::Key;

use strict;
use warnings;

sub create {
    my $self    = shift;
    my $user    = $self->session('user');
    my $matcher = $self->param('matcher');

}

1;