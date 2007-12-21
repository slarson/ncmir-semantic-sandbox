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
# updated 06/10/07 : added abbreviation of brain part parent

my $reader = new XML::LibXML::Reader(location => "swanson-98.xml")
    or die "cannot read file.xml\n";

#read through once and build up an id->abbrev lookup table
my %brainPartID = ();
while ($reader->read) {
    if ($reader->nodeType == 1) {
	if ($reader->name eq "part") {
	    my $id = $reader->getAttribute("id");
	    my $numId;
	    if ($id =~ /[A-Za-z](\d+)/) {
		$numId = $1;
	    }
	    $brainPartID{$numId} = $reader->getAttribute("abbreviation");
	}
    }
}


$reader = new XML::LibXML::Reader(location => "swanson-98.xml")
    or die "cannot read file.xml\n";

my $dom = XML::LibXML::Document->new();
# create root node
my $root = $dom->createElementNS( "", "Parts" );
$dom->setDocumentElement( $root );

while ($reader->read) {
    # for element nodes
    if ($reader->nodeType == 1) {
	# for nodes that talk about molecules
	if ($reader->name eq "part") {

	    # pull out id tag and strip out non digit portions
	    my $id = $reader->getAttribute("id");
	    my $numId;
	    if ($id =~ /[A-Za-z](\d+)/) {
		$numId = $1;
	    }

	    my $idref = $reader->getAttribute("is_part_of_idrefs");
	    my $numIdref;
	    if ($idref) {
		if ($idref =~ /[A-Za-z](\d+)/) {
		    $numIdref = $1;
		}
	    }

	    #write part information element
	    my $node = $root->addNewChild("", "Part");
	    $node->setAttribute("id",$numId);
	    $node->setAttribute("name",$reader->getAttribute("name"));
	    $node->setAttribute("abbrev",$reader->getAttribute("abbreviation"));
	    if ($idref) {
		$node->setAttribute("is_part_of_id",$numIdref);
		$node->setAttribute("is_part_of_abbrev",$brainPartID{$numIdref});
	    }

	    my $node2 = $reader->copyCurrentNode(1);
	    my $xpc = XML::LibXML::XPathContext->new($node2);

	    #write cells belonging to this part
	    my @nodes = $xpc->findnodes('//cells/cell');
	    #only if there are some cells in this part
	    if ($#nodes > 0) {
		my $cellsNode = $node->addNewChild("", "Cells");
		foreach my $node2 (@nodes) {
		    my $cellNode = $cellsNode->addNewChild("", "Cell");
		    
		    # pull out id tag and strip out non digit portions
		    my $id2 = $node2->getAttribute("id");
		    my $numId2;
		    if ($id2 =~ /[A-Za-z](\d+)/) {
			$numId2 = $1;
		    }
		    
		    $cellNode->setAttribute("id", $numId2);
		}
	    }

	    #write molecules belonging to this part
	    my @nodes2 = $xpc->findnodes('//molecules_in_region/molecule_in_region');
	    #only if there are some molecules in this part
	    if ($#nodes2 > 0) {
		my $molsNode = $node->addNewChild("", "Molecules");
		foreach my $node2 (@nodes2) {
		    my $molNode = $molsNode->addNewChild("", "Molecule");
		    
		    # pull out id tag and strip out non digit portions
		    my $id2 = $node2->getAttribute("id");
		    my $numId2;
		    if ($id2 =~ /[A-Za-z](\d+)/) {
			$numId2 = $1;
		    }
		    
		    $molNode->setAttribute("id", $numId2);
		}
	    }
	}
    }
}

#print the xml file out
my $str = $dom->toStringHTML();
print $str;
