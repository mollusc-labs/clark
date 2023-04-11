package Clark::Schema::ResultSet::Key;

use parent 'Clark::Schema::Base::ResultSet';
use DateTime;
use strict;
use warnings;

sub active {
    my $self = shift;
    return $self->search( { is_active => 1 } );
}

sub by_key {
    my $self = shift;
    return $self->active->search( { key => pop } );
}

sub by_id {
    my $self = shift;
    return $self->active->search( { id => pop } );
}

1;