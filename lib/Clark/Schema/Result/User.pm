package Clark::Schema::Result::User;

use strict;
use warnings;
use DateTime;
use Clark::Util::Crypt;
use base 'DBIx::Class::Core';

__PACKAGE__->load_components(qw/InflateColumn::DateTime PK::Auto Core/);

__PACKAGE__->table('user');
__PACKAGE__->add_columns(
    id => {
        data_type         => 'varchar',
        size              => 36,
        unique            => 1,
        is_auto_increment => 1
    },
    name => {
        data_type => 'varchar',
        size      => 50,
        unique    => 1
    },
    password => {
        data_type => 'varchar',
        size      => 100
    },
    is_admin => {
        data_type => 'tinyint',
        size      => 1
    },
    qw/last_login created_at /
);

__PACKAGE__->mk_group_accessors();
__PACKAGE__->set_primary_key('id');

1;