#!/usr/bin/perl -w
use strict;

use XML::LibXML::Reader;
use XML::LibXML::XPathContext;
use XML::LibXML;

# Separate out part tags from swanson-98.xml into a separate file
# that just collects information on the parts.

#
# slarson@ncmir.ucsd.edu
# 05/27/07

my $reader = new XML::LibXML::Reader(location => "swanson-98.xml")
    or die "cannot read file.xml\n";

my $dom = XML::LibXML::Document->new();
# create root node
my $root = $dom->createElementNS( "", "Connections" );
$dom->setDocumentElement( $root );


my %visitedHash = ();
while ($reader->read) {
    # for element nodes
    if ($reader->nodeType == 1) {
	# for nodes that talk about parts
	if ($reader->name eq "part") {
	    my $node2 = $reader->copyCurrentNode(1);

	    # pull out id tag and strip out non digit portions
	    my $id = $reader->getAttribute("id");
	    my $numId;
	    if ($id =~ /[A-Za-z](\d+)/) {
		$numId = $1;
	    }

	    my $abbrev = $reader->getAttribute("abbreviation");

	    my $targetNode = ($node2->getChildrenByLocalName("targets"))[0];
	    my @nodes;
	    if ($targetNode) {
		@nodes = $targetNode->getChildrenByLocalName("target");
	    }

	    #only if there are some targets in this part
	    if (@nodes > 0) {

		foreach my $node2 (@nodes) {

		    #write connection information element
		    my $node = $root->addNewChild("", "Connection");
		    
		    # pull out id tag and strip out non digit portions
		    my $id2 = $node2->getAttribute("id");
		    my $numId2;
		    if ($id2 =~ /[A-Za-z](\d+)/) {
			$numId2 = $1;
		    }

		    my $abbrev2 = $node2->getAttribute("abbreviation");
		    
		    $node->setAttribute("source_id", $numId);
		    $node->setAttribute("target_id", $numId2);

		    my $name = $abbrev."_to_".$abbrev2;
		    $node->setAttribute("name",$name);

		    $node->setAttribute("url","aff=$numId2&eff=$numId");	
		    if ($visitedHash{$name}){
			$node->unbindNode();
		    }
		    $visitedHash{$name} = $id2;
		}
	    }

	    my $sourceNode = ($node2->getChildrenByLocalName("sources"))[0];
	    my @nodes3;
	    if ($sourceNode) {
		@nodes3 = $sourceNode->getChildrenByLocalName("source");
	    }

	    #only if there are some sourcess in this part
	    if (@nodes3 > 0) {

		foreach my $node2 (@nodes3) {

		    #write connection information element
		    my $node = $root->addNewChild("", "Connection");

	    
		    # pull out id tag and strip out non digit portions
		    my $id2 = $node2->getAttribute("id");
		    my $numId2;
		    if ($id2 =~ /[A-Za-z](\d+)/) {
			$numId2 = $1;
		    }

		    my $abbrev2 = $node2->getAttribute("abbreviation");
		    
		    $node->setAttribute("target_id", $numId);
		    $node->setAttribute("source_id", $numId2);

		    my $name = $abbrev2."_to_".$abbrev;
		    $node->setAttribute("name",$name);

		    $node->setAttribute("url","eff=$numId2&aff=$numId");	

		    if ($visitedHash{$name}){
			$node->unbindNode();
		    }
		    $visitedHash{$name} = $id2;
		}
	    }
	}
    }
}

#print the xml file out
$dom->toFile("cnxns.xml", 1);
