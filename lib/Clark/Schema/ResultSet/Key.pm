package Clark::Schema::ResultSet::Key;

use parent 'Clark::Schema::Base::ResultSet';
use DateTime;
use strict;
use warnings;

sub active {
    return shift->search( { is_active => 1 } );
}

sub by_key {
    return shift->active->find( { value => pop } );
}

sub by_id {
    return shift->active->find( { id => pop } );
}

1;