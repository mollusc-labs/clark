package Clark::Schema::ResultSet::Log;

use base 'DBIx::Class::ResultSet';
use DateTime;
use Scalar::Util qw(looks_like_number);
use Data::Dumper;
use strict;
use warnings;
use v5.10;    # for state
use Clark::Schema;

sub by_params {
    my $self = shift;
    my %args = @_;
    my $size = $args{'size'};
    my $page = $args{'page'};

    if ( looks_like_number $page ) {
        delete $args{'page'};
    }

    if ( looks_like_number $size ) {
        delete $args{'size'};
    }

    return $self->latest($size)->search(
        \%args || {},
        {   page => $page || 1,
            rows => $size || 10,
            { order_by => { -desc => 'created_at' } }
        }
    );
}

sub by_service {
    my $self = shift;
    my $page = shift;
    my $size = shift;
    my $name = pop;

    $page = 1  unless looks_like_number $size;
    $size = 10 unless looks_like_number $size;
    return $self->search(
        { service_name => $name },
        {   page => $page,
            rows => $size
        }
    );
}

sub from_date {
    my $self = shift;
    my $from = shift || DateTime->epoch( epoch => 0 );
    my $to   = pop   || DateTime->now;

    my $dtf = $self->result_source->storage->datetime_parser;
    return $self->search( { created_at => { -between => [ $dtf->format_datetime($from), $dtf->format_datetime($to) ] } }, { order_by => { -desc => 'created_at' } } );
}

sub by_severity {
    return shift->search( { severity => pop }, { order_by => { -desc => 'created_at' } } );
}

sub latest {
    my $self = shift;
    my $rows = pop;
    $rows = 20 unless looks_like_number $rows;

    return $self->search( {}, { order_by => { -desc => 'created_at' }, rows => $rows } );
}

sub today {
    state $delta = 24 * 60 * 60 * 1000;
    my $c            = shift;
    my $service_name = pop;

    $c->from_date( DateTime->from_epoch( epoch => ( time - $delta ) ) )->search( { service_name => $service_name }, { order_by => { -desc => 'created_at ' } } );
}

1;