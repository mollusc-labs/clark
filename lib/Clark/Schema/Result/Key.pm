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
        unique    => 1,
        is_uuid   => 1
    },
    value => {
        data_type => 'varchar',
        size      => 100,
        unique    => 1,
        not_null  => 1
    },
    matcher => {
        data_type => 'varchar',
        size      => 100,
        not_null  => 1
    },
    created_by => {
        data_type => 'varchar',
        size      => 36
    },
    qw/ is_active created_at inactive_since /
);
__PACKAGE__->set_primary_key('id');

1;