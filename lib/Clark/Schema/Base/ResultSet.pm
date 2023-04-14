package Clark::Schema::Base::ResultSet;

use strict;
use warnings;
use Clark::Util::UUID;
use base 'DBIx::Class::ResultSet';

sub create {
    my $self = shift;
    my $qry  = shift;
    $qry->{id} = Clark::Util::UUID->new unless ( $qry->{id} );
    return $self->SUPER::create($qry);
}

1;