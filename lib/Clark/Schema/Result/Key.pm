package Clark::Schema::Result::Key;

use strict;
use warnings;
use DateTime;
use base 'DBIx::Class::Core';

__PACKAGE__->load_components(qw/InflateColumn::DateTime PK::Auto Core/);

__PACKAGE__->table('api_key');
__PACKAGE__->add_columns(
    id => {
        data_type => 'varchar',
        size      => 36,
        unique    => 1
    },
    qw/ value matcher created_by is_active created_at inactive_since /
);
__PACKAGE__->set_primary_key('id');

1;