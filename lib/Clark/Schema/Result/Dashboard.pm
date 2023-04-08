package Clark::Schema::Result::Dashboard;

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
    owner => {
        data_type => 'varchar',
        size      => 36
    },
    qw/ name query /
);
__PACKAGE__->set_primary_key('id');

1;