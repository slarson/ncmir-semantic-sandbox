#!/usr/bin/perl -w

my $toggle = 1;
while (<>) {


    if ($_ =~ /<rdf:Property rdf:about="(.*)">/) {
	    $toggle = 0;
    }

    if ($_ =~ /<rdf:Property rdf:ID="(.*)">/) {
	    $toggle = 0;
    }

    if ($_ =~ /<rdf:Property rdf:about="(.*)"\/>/) {
	next;
    }

    if ($_ =~ /<rdf:Property rdf:ID="(.*)"\/>/) {
	next;
    }
    if ($toggle) {
	print STDOUT;
    }
    if ($_ =~ /<\/rdf:Property>/) {
	$toggle = 1;
    }
}
