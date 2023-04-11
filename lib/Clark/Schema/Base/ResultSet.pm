package Clark::Schema::Base::ResultSet;

use strict;
use warnings;
use Clark::Util::UUID;
use base 'DBIx::Class::ResultSet';

sub create {
    my $self = shift;
    my $qry  = shift;
    print 'foo' . "\n";
    return $self->SUPER::create( { %{$qry}, id => Clark::Util::UUID->new } );
}

1;