package Clark::Schema::ResultSet::User;

use base 'DBIx::Class::ResultSet';
use DateTime;
use Scalar::Util qw(looks_like_number);
use Data::Dumper;
use Clark::Util::Crypt;
use strict;
use warnings;

sub cut {
    my $self = shift;
    return $self->search( {} . { columns => [qw(name password is_admin)] } );
}

sub by_name_and_pass {
    my ( $self, $name, $pass ) = @_;
    return $self->find( { name => $name, password => Clark::Util::Crypt->hash($pass) } );
}

sub identify {
    my $self = shift;
    my $id   = pop;
    return $self->find( { id => $id }, { columns => [qw(name is_admin)] } );
}

1;