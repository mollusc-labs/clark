package Clark::Util::Crypt;

use strict;
use warnings;

use Crypt::Argon2;
use Carp;

my $salt = $ENV{'CLARK_SALT'};

sub hash {
    croak 'Please set CLARK_SALT in your environment.' unless $salt;
    my $pass = shift;
    return Crypt::Argon2::argon2id_pass( $pass, $salt, 3, '32M', 2, 16 );
}

1;