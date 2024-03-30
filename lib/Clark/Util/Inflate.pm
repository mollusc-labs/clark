
package Clark::Util::Inflate;

use strict;
use warnings;

sub many {
    my $s = shift;

    my @a = map( {
            { $_->get_inflated_columns }
    } @_ );

    return \@a;
}

1;

