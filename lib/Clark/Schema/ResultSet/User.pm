package Clark::Schema::ResultSet::User;

use parent 'Clark::Schema::Base::ResultSet';
use DateTime;
use Scalar::Util qw(looks_like_number);
use Data::Dumper;
use Clark::Util::Crypt;
use strict;
use warnings;

sub cut {
    my $self = shift;
    return $self->search( {}, { columns => [qw(id name is_admin)] } );
}

sub by_name_and_pass {
    my ( $self, $name, $pass ) = @_;
    my $hash = Clark::Util::Crypt->hash($pass);
    return $self->find( { name => $name, password => $hash } );
}

sub identify {
    my $self = shift;
    my $id   = pop;
    return $self->cut->find( { id => $id } );
}

1;