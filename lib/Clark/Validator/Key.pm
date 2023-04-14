package Clark::Validator::Key;

use strict;
use warnings;
use JSON::Validator;
use JSON::Validator::Joi 'joi';
use Mojo::Base -base;

has validator => sub {
    my $self      = shift;
    my $validator = JSON::Validator->new;
    $validator->schema(
        joi->object->props(
            {   matcher    => joi->string->required,
                created_by => joi->string->required->length(36),
                value      => joi->string->required->max(1000)
            }
        )
    );
};

1;