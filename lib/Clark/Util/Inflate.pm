
package Clark::Util::Inflate;

use strict;
use warnings;
use v5.36;

sub many (@columns) {
    return \map( {
            { $_->get_inflated_columns }
    } @columns );
}

1;