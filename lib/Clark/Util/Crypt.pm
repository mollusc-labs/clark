package Clark::Util::Crypt;

use strict;
use warnings;

use Crypt::Argon2;
use Carp;

my $salt = $ENV{'SALT'} || 'CHANGE_ME';

sub hash_password {
    my $pass = shift;
    return argon2id_pass( $pass, $salt, 3, '32M', 1, 16 );
}

1;