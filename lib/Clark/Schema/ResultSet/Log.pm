package Clark::Schema::ResultSet::Log;

use parent 'Clark::Schema::Base::ResultSet';
use DateTime;
use Scalar::Util qw(looks_like_number);
use Data::Dumper;
use strict;
use warnings;
use v5.10;    # for state

sub by_params {
    my $self = shift;
    my $args = {@_};

    my $size = $args->{'size'};
    my $page = $args->{'page'};

    $size = 10 unless looks_like_number $size;
    $page = 1  unless looks_like_number $page;

    delete $args->{'page'};
    delete $args->{'size'};

    if ( $args->{'text'} ) {

   # Custom full-text search for text fields: message, service_name and hostname
        return $self->result_source->storage->dbh_do(
            sub {
                my $s = shift;
                my $d = shift;
                my $t = $args->{'text'};
                delete $args->{'text'};

                my $q    = join ' ', map {"AND $_ = ?"} ( keys %{$args} );
                my $rows = $d->selectall_arrayref(
                    qq[
                    SELECT * FROM log WHERE MATCH (message, service_name, hostname)
                    AGAINST (?) $q ORDER BY created_at DESC LIMIT ?
                ], { Slice => {} }, values %{$args}, $t, $size
                );

                return map { $self->new_result($_) } @{$rows};
            }
        );
    }

    return $self->latest($size)->search(
        $args,
        {   page => $page,
            rows => $size,
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
    my $to   = shift || DateTime->now;
    my $rows = pop;

    $rows = 20 unless looks_like_number $rows;

    # Need to inflate date-times for searching, using datetime_parser
    my $dtf = $self->result_source->storage->datetime_parser;
    return $self->search(
        {   created_at => {
                -between => [
                    $dtf->format_datetime($from), $dtf->format_datetime($to)
                ]
            }
        },
        {   order_by => { -desc => 'created_at' },
            rows     => $rows
        }
    );
}

sub by_severity {
    return shift->search( { severity => pop },
        { order_by => { -desc => 'created_at' } } );
}

sub latest {
    my $self = shift;
    my $rows = pop;
    $rows = 20 unless looks_like_number $rows;

    return $self->search(
        {},
        {   order_by => { -desc => 'created_at' },
            rows     => $rows
        }
    );
}

sub today {
    state $delta = 24 * 60 * 60 * 1000;
    my $c            = shift;
    my $service_name = shift;
    my $rows         = shift;

    $rows = 20 unless looks_like_number $rows;

    $c->from_date( DateTime->from_epoch( epoch => ( time - $delta ) ) )
        ->search(
        { service_name => $service_name },
        {   order_by => { -desc => 'created_at ' },
            rows     => $rows
        }
        );
}

sub create {
    my $self = shift;
    my $obj  = shift;

    return $self->new_result( { %{$obj}, retrieve_on_insert => 1 } )->insert;
}

1;