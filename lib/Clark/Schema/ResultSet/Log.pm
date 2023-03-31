package Clark::Schema::ResultSet::Log;

use base 'DBIx::Class::ResultSet';
use DateTime;
use Scalar::Util qw(looks_like_number);
use Data::Dumper;
use strict;
use warnings;
use v5.10;    # for state

sub by_params {
    my $c    = shift;
    my %args = @_;
    ( my $size = $args{'size'} ) and delete $args{'size'};
    my $page = $args{'page'};

    if ( looks_like_number $page ) {
        delete $args{'page'};
    }
    else { $page = 1 }

    if ( looks_like_number $size ) {
        delete $args{'size'};
    }
    else { $size = 10 }

    return $c->search( {}, { page => $page, rows => $size } );
}

sub by_service {
    my $c    = shift;
    my $page = shift;
    my $size = shift;
    my $name = pop;
    $page = 1  unless looks_like_number $size;
    $size = 10 unless looks_like_number $size;
    return $c->search(
        { service_name => $name },
        {   page => $page,
            rows => $size
        }
    );
}

sub from_date {
    my $c    = shift;
    my $from = shift || DateTime->epoch( epoch => 0 );
    my $to   = shift || DateTime->now;
    return $c->search( { created_at => { -between => [ $from, $to ] } } );
}

sub by_severity {
    return shift->search( { severity => { LIKE => pop } } );
}

sub latest {
    my $c    = shift;
    my $rows = pop;
    $rows = 20 unless looks_like_number $rows;
    return $c->search( {}, { order_by => { -desc => 'created_at' }, rows => $rows } );
}

sub today {
    state $delta = 24 * 60 * 60 * 1000;
    my $c            = shift;
    my $service_name = pop;
    $c->from_date( DateTime->from_epoch( epoch => ( time - $delta ) ) )->search( { service_name => $service_name } );
}

1;