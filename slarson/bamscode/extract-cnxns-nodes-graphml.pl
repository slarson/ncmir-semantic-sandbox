#!/usr/bin/perl -w
use strict;

use XML::LibXML::Reader;
use XML::LibXML::XPathContext;
use XML::LibXML;

# Convert swanson-98.xml into a graphml format

#
# slarson@ncmir.ucsd.edu
# 10/29/07

my $reader = new XML::LibXML::Reader(location => "swanson-98.xml")
    or die "cannot read file.xml\n";

my $dom = XML::LibXML::Document->new();
# create root node
my $root = $dom->createElementNS( "http://graphml.graphdrawing.org/xmlns", "graphml" );
$dom->setDocumentElement( $root );

my $graph = $root->addNewChild("", "graph");
$graph->setAttribute("edgedefault","directed");

my $key = $graph->addNewChild("","key");
$key->setAttribute("id","name");
$key->setAttribute("for","node");
$key->setAttribute("attr.name","name");
$key->setAttribute("attr.type","string");

my %nodesHash = ();
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
		    my $node = $graph->addNewChild("", "edge");
		    
		    # pull out id tag and strip out non digit portions
		    my $id2 = $node2->getAttribute("id");
		    my $numId2;
		    if ($id2 =~ /[A-Za-z](\d+)/) {
			$numId2 = $1;
		    }

		    my $abbrev2 = $node2->getAttribute("abbreviation");

		    #repetative, but insures that only nodes that have connections
		    #will be included
		    $nodesHash{$numId} = $abbrev;

		    $nodesHash{$numId2} = $abbrev2;

		    $node->setAttribute("source", $numId);
		    $node->setAttribute("target", $numId2);

		    #deal with duplicates
		    my $name = $abbrev."_to_".$abbrev2;
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

	    #only if there are some sources in this part
	    if (@nodes3 > 0) {

		foreach my $node2 (@nodes3) {

		    #write connection information element
		    my $node = $graph->addNewChild("", "edge");

	    
		    # pull out id tag and strip out non digit portions
		    my $id2 = $node2->getAttribute("id");
		    my $numId2;
		    if ($id2 =~ /[A-Za-z](\d+)/) {
			$numId2 = $1;
		    }

		    my $abbrev2 = $node2->getAttribute("abbreviation");

		    #repetative, but insures that only nodes that have connections
		    #will be included
		    $nodesHash{$numId} = $abbrev;
		    
		    $nodesHash{$numId2} = $abbrev2;

		    $node->setAttribute("target", $numId);
		    $node->setAttribute("source", $numId2);

		    #deal with duplicates
		    my $name = $abbrev2."_to_".$abbrev;
		    if ($visitedHash{$name}){
			$node->unbindNode();
		    }
		    $visitedHash{$name} = $id2;
		}
	    }
	}
    }
}
foreach my $key (keys(%nodesHash)) {
    my $node = $graph->addNewChild("","node");
    $node->setAttribute("id", $key);
    my $data = $node->addNewChild("", "data");
    $data->setAttribute("key", "name");
    $data->appendText($nodesHash{$key});
}

#print the xml file out
$dom->toFile("cnxns-nodes-graphml.xml", 1);
