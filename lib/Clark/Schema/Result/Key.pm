package Clark::Schema::Result::Key;

use strict;
use warnings;
use DateTime;
use base 'DBIx::Class::Core';

__PACKAGE__->load_components(qw/InflateColumn::DateTime PK::Auto Core/);

__PACKAGE__->table('api_key');
__PACKAGE__->add_columns(
    id => {
        data_type         => 'varchar',
        size              => 36,
        unique            => 1,
        is_auto_increment => 1
    },
    key => {
        data_type => 'varchar',
        size      => 100,
        unique    => 1
    },
    matcher => {
        data_type => 'varchar',
        size      => 100
    },
    qw/ is_active matcher /
);
__PACKAGE__->set_primary_key('id');

1;