#!/usr/bin/perl -w

my $toggle = 1;
while (<>) {


    if ($_ =~ /<rdf:Property rdf:about="(.*)">/) {
	if ($1 =~ /skos/) {
	    $toggle = 0;
	}
    }
    if ($toggle) {
	print STDOUT;
    }
    if ($_ =~ /<\/rdf:Property>/) {
	$toggle = 1;
    }
}
