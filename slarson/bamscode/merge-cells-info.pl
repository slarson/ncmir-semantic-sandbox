#!/usr/bin/perl -w
use strict;

use XML::LibXML::Reader;
use XML::LibXML::XPathContext;
use XML::LibXML;

# Merges info on brain parts extracted from swanson-98
# with an OWL ontology also produced from swanson-98 which
# uses names rather than IDs to refer to entities
#
#
# slarson@ncmir.ucsd.edu
# 06/19/07

#build up a data structure that has the mappings between ids and names
my %idsNames = ();
my $reader = new XML::LibXML::Reader(location => "cells.owl");

my $id;
while ($reader->read) {
    if ($reader->nodeType == 1) {
	
	if ($reader->name eq "owl:Class") {
	    $id = $reader->getAttribute("rdf:ID");
	}

	if ($reader->name eq "bams_cell_id") {
	    $reader->read;
	    $idsNames{$reader->value} = $id;
	    #my $x = $reader->value;
	    #print "$id $x\n";
	}
    }
}

my $parser = XML::LibXML->new();

my $doc = $parser->parse_file("brainparts-with-fixed-canonicals.xml");

my $xc = XML::LibXML::XPathContext->new($doc);

my @nodes = $xc->findnodes('/Parts/Part/Cells/Cell');

foreach my $node (@nodes) {
    my $id = $node->getAttribute("id");
    #print $id;
    if ($idsNames{$id}) {
	$node->setAttribute("ontology_name", $idsNames{$id});
    } else {
	print "no name for id $id ? \n";
    }
}
    
#print the xml file out
my $str = $doc->toStringHTML();
print $str;
