package Clark::Schema::Result::Dashboard;

use strict;
use warnings;
use DateTime;
use base 'DBIx::Class::Core';

__PACKAGE__->load_components(qw/InflateColumn::DateTime PK::Auto Core/);

__PACKAGE__->table('dashboard');
__PACKAGE__->add_columns(
    id => {
        data_type     => 'char',
        size          => 36,
        set_on_create => 1
    },
    owner => {
        data_type => 'char',
        size      => 36
    },
    qw/name query created_at/
);
__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to( 'user' => 'Clark::Schema::Result::User', 'id' );

1;