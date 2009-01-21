#!perl

use strict;
use warnings;
use UNIVERSAL qw(isa);
use lib '../lib';
use Test::More tests => 4;
use Test::CallFlow qw(:all); # package under test

package Foo;
use vars qw($original_called);

sub mockable { "real sub called " . ++$original_called . " times" };

package main;

mock_package( 'Foo' );
record_calls_from( 'RecordTests' );

is( Test::CallFlow::instance()->{state}, $Test::CallFlow::state{record}, "Recording state activated" );

package RecordTests;

sub test_recording {
  Foo::mockable;
}

package main;

my $out = RecordTests::test_recording();
is( $out, "real sub called 1 times", "Call through recording mock returns value from real call" );

mock_reset();
mock_run();

$out = RecordTests::test_recording();
is( $out, "real sub called 1 times", "Call to recorded mock returns a recorded value" );

mock_end();
mock_clear();

$out = RecordTests::test_recording();
is( $out, "real sub called 2 times", "Call after mock_clear goes to original sub" );

