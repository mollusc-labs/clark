package Clark::Validator::Dashboard;

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
            {   query => joi->string->required->regex("^\\?."),
                name  => joi->string->required,
                owner => joi->string->required->length(36)
            }
        )
    );
};

sub validate {
    my $self   = shift;
    my @errors = $self->validator->validate(pop);
    return \@errors;
}

1;

