package Clark::Schema::Result::Log;

use strict;
use warnings;
use experimental qw(signatures);
use Mojo::Util   qw(secure_compare);
use DateTime;
use base 'DBIx::Class::Core';

__PACKAGE__->load_components('InflateColumn::DateTime');

__PACKAGE__->table('log');
__PACKAGE__->add_columns(qw/ id service_name severity message created_at /);
__PACKAGE__->set_primary_key('id');

1;