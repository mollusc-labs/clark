#!/usr/bin/env perl

use strict;
use warnings;
use IO::Prompter;
use Term::ReadKey;
use Carp;

eval { unlink '.env' };

my %env;

print "Welcome to the clark environment setup script.\n\n";
print "Please provide the following information.\n\n";
$env{'MYSQL_PASS'} = prompt 'Database password:', -echo => '*';
sleep 1;

print "\nPlease input the credentials you wish to use for the default clark account (you can change these later).\n\n";
$env{'CLARK_USER'} = prompt 'Username:';
$env{'CLARK_PASS'} = prompt 'Password:', -echo => '*';
sleep 1;

print "\nGenerating secure salt\n";
$env{'CLARK_SALT'} = `echo "$(date)$(uname -a)" | sha256sum | cut -d' ' -f1`;
sleep 2;
print "\nGenerating API key\n";
$env{'CLARK_API_KEY'} = `echo "$(date)$(uname -a)" | md5sum | cut -d' ' -f1`;
sleep 1;

my $str = join( "\n", map { chomp( $env{$_} ); "$_=$env{$_}" } keys %env );
open( my $fh, '>', '.env' ) || croak 'Could not open file .env';
chomp($str);
print $fh "$str";
close $fh;

print "\nFinished setting up clark environment. Please review the .env file that was generated.\n";
print "NOTE: The CLARK_API_KEY is your MASTER key, meaning it is used to generate more keys, please keep it safe.\n\n";