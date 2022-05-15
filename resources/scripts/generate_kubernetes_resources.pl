#!/usr/bin/env perl -w
use JSON::XS;
use LWP::Simple;

use strict;

my @definitions_url = ("https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/", "/_definitions.json");
my @versions;
my %kinds;

my $gh_tree_content = get("https://api.github.com/repos/yannh/kubernetes-json-schema/git/trees/master");
if(!defined $gh_tree_content) {
  die "Can't GET GH tree";
}

my %seen_version;
my $gh_tree = decode_json $gh_tree_content;
foreach my $tree (@{$gh_tree->{'tree'}}) {
  if($tree->{'path'} =~ /^(v\d+\.\d+)\.\d+$/) {
    if(!defined $seen_version{$1}) {
      push(@versions, $tree->{'path'});
    }
  }
}

foreach my $version (@versions[-10..-1]) {
  my $url = $definitions_url[0] . $version . $definitions_url[1];

  my $content = get($url);
  if(!defined $content) {
    die "Can't GET $url";
  }

  my $definitions = decode_json $content;
  foreach my $definition_key (keys %{$definitions->{'definitions'}}) {
    if(! defined $definitions->{definitions}{$definition_key}->{'x-kubernetes-group-version-kind'}) {
      next;
    }

    my $kubernetes_group_version_kind = $definitions->{definitions}{$definition_key}->{'x-kubernetes-group-version-kind'};
    foreach my $version_kind (@{$kubernetes_group_version_kind}) {
      $kinds{$version_kind->{'kind'}} = 1;
    }
  }
  sleep(1);
}

print("-- AUTOMATICALLY GENERATED\n-- DO NOT EDIT\n");
print("return {\n  \"");
print(join("\",\n  \"", sort(keys %kinds)));
print("\",\n}\n");
