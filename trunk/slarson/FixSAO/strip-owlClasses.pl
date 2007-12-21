#!/usr/bin/perl -w

my $toggle = 0;
while (<>) {


    if ($_ =~ /<owl:Class rdf:about="(.*)">/) {
	$toggle++;
    } elsif (/<owl:Class rdf:ID="(.*)">/) {
	$toggle++;
    } elsif ($_ =~ /<owl:Class rdf:about="(.*)"\/>/) {
	next;
    } elsif (/<owl:Class rdf:ID="(.*)"\/>/) {
	next;
    } elsif ((/<owl:Class.*\/>/) & ($toggle > 0)) {
    } elsif ((/<owl:Class/) & ($toggle > 0)) {
	$toggle++;
    }
    if ($toggle == 0) {
	print STDOUT;
    }
    if (($_ =~ /<\/owl:Class>/) & ($toggle > 0)) {
	$toggle--;
    }
}
