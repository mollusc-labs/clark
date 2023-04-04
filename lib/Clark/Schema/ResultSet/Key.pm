package Clark::Schema::ResultSet::Key;

use base 'DBIx::Class::ResultSet';
use DateTime;
use strict;
use warnings;

sub active {
    my $self = shift;
    return $self->search( { is_active => 1 } );
}

1;