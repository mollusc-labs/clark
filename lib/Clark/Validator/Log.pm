package Clark::Validator::Log;

use warnings;
use strict;
use JSON::Validator;
use Mojo::Base -base;

has schema => sub {
    return {
        type       => 'object',
        required   => [ 'severity', 'service_name', 'message' ],
        properties => [
            severity     => { type => 'integer', minimum => 0, maximum => 7 },
            service_name => { type => 'string' },
            message      => { type => 'string' }
        ]
    };
};

sub validate {
    my $self      = shift;
    my $validator = JSON::Validator->new;
    $validator->schema( $self->schema );
    my @errors = $validator->validate(pop);
    return \@errors;
}

sub new {
    return bless {}, pop;
}

1;