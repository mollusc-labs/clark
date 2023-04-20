#!/usr/bin/env perl

use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'Clark',
    VERSION_FROM => 'lib/Clark.pm',
    ABSTRACT     => 'Free and Open-Source logging dashboard',
    AUTHOR       => 'Mollusc Labs',
    LICENSE      => 'bsd',
    PREREQ_PM    => {
        'Mojolicious'             => 0,
        'Bread::Board'            => 0,
        'DBI'                     => 0,
        'DBD::mysql'              => 0,
        'DBIx::Class'             => 0,
        'Crypt::Argon2'           => 0,
        'DateTime'                => 0,
        'Crypt::JWT'              => 0,
        'DateTime::Format::MySQL' => 0,
        'JSON::Validator'         => 0,
        'Data::UUID'              => 0
    },
    test => { TESTS => 't/*.t t/*/*.t' }
);