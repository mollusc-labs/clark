use strict;
use warnings;

use Mojo::File qw(curfile);
use lib curfile->sibling('lib')->to_string;
use Clark::Validator::Dashboard;
use Clark::Validator::Log;
use Test::Simple tests => 6;

my $validator = Clark::Validator::Dashboard->new;

ok( defined $validator, 'Is not undef?' );

my $json = { foo => '' };

ok( scalar $validator->validate($json), 'Is invalid data invalid?' );

my $good_json = {
    name  => 'foo',
    query => '?foo=bar',
    owner => '70d91a66-d754-11ed-a062-0242ac130002'
};
ok( scalar( @{ $validator->validate($good_json) } ) == 0,
    'Is valid data valid?' );

my $log_validator = Clark::Validator::Log->new;

ok( defined $log_validator,                 'Is not undef?' );
ok( scalar $log_validator->validate($json), 'Is invalid data invalid?' );

my $good_json_log = {
    severity     => 1,
    service_name => 'Foo-service',
    message      => '70d91a66-d754-11ed-a062-0242ac130002'
};
ok( scalar( @{ $log_validator->validate($good_json_log) } ) == 0,
    'Is valid data valid?' );