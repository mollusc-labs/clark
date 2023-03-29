package Clark::Schema::Result::User;

use strict;
use warnings;
use experimental qw(signatures);
use Mojo::Util   qw(secure_compare);
use DateTime;
use Clark::Util::Crypt;
use base 'DBIx::Class::Core';

__PACKAGE__->load_components('InflateColumn::DateTime');

__PACKAGE__->table('user');
__PACKAGE__->add_columns(qw/ id name password is_admin last_login created_at /);
__PACKAGE__->set_primary_key('id');

1;