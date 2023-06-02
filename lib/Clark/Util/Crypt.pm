package Clark::Util::Crypt;

use strict;
use warnings;

use Crypt::Argon2;
use Carp qw(croak);
use Readonly;

Readonly::Scalar my $salt => $ENV{'CLARK_SALT'};

sub hash {
    my ( $self, $pass ) = @_;
    croak 'Please set CLARK_SALT in your environment.' unless $salt;
    return Crypt::Argon2::argon2id_pass( $pass, $salt, 3, '32M', 2, 16 );
}

1;