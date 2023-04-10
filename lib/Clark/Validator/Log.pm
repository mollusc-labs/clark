package Clark::Validator::Log;

use warnings;
use strict;
use JSON::Validator;
use JSON::Validator::Joi 'joi';
use Mojo::Base -base;

has validator => sub {
    my $self      = shift;
    my $validator = JSON::Validator->new;
    $validator->schema(
        joi->object->props(
            {   severity     => joi->string->required->minimum(0)->maximum(7),
                service_name => joi->string->required,
                message      => joi->string->required
            }
        )
    );
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