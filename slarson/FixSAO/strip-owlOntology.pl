#!/usr/bin/perl -w

my $toggle = 0;
while (<>) {


    if ($_ =~ /<owl:Ontology rdf:about="(.*)">/) {
	$toggle++;
    } elsif (/<owl:Ontology rdf:ID="(.*)">/) {
	$toggle++;
    } elsif ($_ =~ /<owl:Ontology rdf:about="(.*)"\/>/) {
	next;
    } elsif (/<owl:Ontology rdf:ID="(.*)"\/>/) {
	next;
    } elsif ((/<owl:Ontology.*\/>/) & ($toggle > 0)) {
    } elsif ((/<owl:Ontology/) & ($toggle > 0)) {
	$toggle++;
    }
    if ($toggle == 0) {
	print STDOUT;
    }
    if (($_ =~ /<\/owl:Ontology>/) & ($toggle > 0)) {
	$toggle--;
    }
}
