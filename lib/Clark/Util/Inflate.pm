
package Clark::Util::Inflate;

use strict;
use warnings;
use Scalar::Util qw(blessed);
use v5.36;

sub many {
    my $s = shift;

    my @a = map( {
            { $_->get_inflated_columns }
    } @_ );

    return \@a;
}

1;