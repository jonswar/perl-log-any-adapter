#!/usr/bin/perl
#test that one can use pre-loaded packages that don't have their own file
use strict;
use warnings;

package MyApp::Log::Adapter;
use base qw(Log::Any::Adapter::Base);
use Log::Any::Adapter::Util qw(make_method);
foreach my $method ( Log::Any->logging_methods() ) {
    make_method($method, sub { print $_[1] });
}
foreach my $method ( Log::Any->detection_methods() ) {
    make_method($method, sub { 1 });
}

package main;
use Test::More tests => 2;
use Test::Exception;
use Capture::Tiny qw(capture_stdout);
use Log::Any::Adapter;

lives_ok {Log::Any::Adapter->set('+MyApp::Log::Adapter')}
    "don't die loading package without a file";
use Log::Any qw($log);

my $stdout = capture_stdout {$log->debug('hello!')};
is($stdout, 'hello!', 'file-less logger works');