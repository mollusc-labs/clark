package Clark::Util::UUID;

use strict;
use warnings;
use Data::UUID;

use Exporter qw/import/;

sub new {
    return lc( Data::UUID->new->create_str );
}

1;