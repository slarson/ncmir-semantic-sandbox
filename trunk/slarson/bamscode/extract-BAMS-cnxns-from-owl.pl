#!/usr/bin/perl -w
use strict;

use XML::LibXML::Reader;
use XML::LibXML;

# Read BAMS.owl file and extract connection & projection 
# strength information

#
# slarson@ncmir.ucsd.edu
# 05/27/07

my $reader = new XML::LibXML::Reader(location => "BAMS.owl")
    or die "cannot read file.xml\n";

my $dom = XML::LibXML::Document->new();
# create root node
my $root = $dom->createElementNS( "", "ConnectionStrengths" );
$dom->setDocumentElement( $root );

my %visitedHash = ();
while ($reader->read) {
    # for element nodes
    if ($reader->nodeType == 1) {
	# for nodes that talk about Connection Statements
	if ($reader->name eq "Connection_Statement") {


	    my $node2 = $reader->copyCurrentNode(1);
	    my $URL = ($node2->getChildrenByLocalName("URL"))[0]->textContent;
	    my $ref = ($node2->getChildrenByLocalName("reference"))[0]->textContent;
	    my $refURLNode = ($node2->getChildrenByLocalName("reference_URL"))[0];
	    my $refURL;
	    if ($refURLNode) {
		$refURL = $refURLNode->textContent;
	    }
	    my $projStr = ($node2->getChildrenByLocalName("projection_Strength"))[0]->textContent;

	    my $source_id;
	    my $target_id;

	    if ($URL =~ /aff=(\d+)/) { $target_id = $1;}

	    if ($URL =~ /eff=(\d+)/) { $source_id = $1;}

	    my $writeNode = $root->addNewChild("", "ConnStrength");
	    $writeNode->setAttribute("source_id", $source_id);
	    $writeNode->setAttribute("target_id", $target_id);
	    my $projStrNode = $writeNode->addNewChild("", "projStr");
	    $projStrNode->appendText("$projStr");

	    # check to see if we have seen this connection before
	    my $source_target = "$source_id $target_id";
	    if ($visitedHash{$source_target}) {
		#if we have, add the projection strength to the
		# first node where we saw this connection and
		# discard this node since it would be a repeat.
		my $oldNode = ${$visitedHash{$source_target}};
		my $append = 1;
		foreach my $oldProjStrNode ($oldNode->getChildrenByLocalName("projStr")) {
		    #make sure we don't add any repeated projection 
		    # strength nodes
		    if ($oldProjStrNode->textContent eq $projStr) {
			$append = 0;
		    }
		}
		# add a new child if we haven't seen a node with this 
		#  projection strength yet
		if ($append) {
		    $oldNode->addNewChild("", "projStr")->appendText("$projStr");
		}
		$writeNode->unbindNode();
	    }
	    $visitedHash{$source_target} = \$writeNode;
	}
    }
}

#print the xml file out
$dom->toFile("cnxns-with-projStrength.xml", 1);
