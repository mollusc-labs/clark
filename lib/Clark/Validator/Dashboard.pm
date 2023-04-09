package Clark::Validator::Dashboard;

use warnings;
use strict;
use JSON::Validator;
use Mojo::Base -base;

has schema => sub {
    return {
        type       => 'object',
        required   => [ 'name', 'query', 'owner' ],
        properties => [
            name  => { type => 'string' },
            query => { type => 'string' },
            owner => { type => 'string' }
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