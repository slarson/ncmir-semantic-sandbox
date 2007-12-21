#!/usr/bin/perl -w

my $toggle = 1;
while (<>) {


    if ($_ =~ /<rdfs:Class rdf:about="(.*)"/) {
	$toggle = 0;
    }
    if ($toggle) {
	print STDOUT;
    }
    if ($_ =~ /<\/rdfs:Class>/) {
	$toggle = 1;
    }
}
