#!/usr/bin/env perl -w
use strict;

my ($version) = @ARGV;
 
if (not defined $version) {
  die "Need version\n";
}

print("-- AUTOMATICALLY GENERATED\n-- DO NOT EDIT\n");
print("return \"v" . $version . "\"\n");
