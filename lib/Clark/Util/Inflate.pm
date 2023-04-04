
package Clark::Util::Inflate;

use strict;
use warnings;
use v5.36;

sub many {
    shift;
    return map( {
            { $_->get_inflated_columns }
    } @_ );
}

1;