#!/usr/bin/perl -w
use strict; 

use XML::LibXML::Reader;
use XML::LibXML;

# Separate out molecule tags from swanson-98.xml into a separate file
# that just collects information on the molecules.
# Throw away duplicates.
#
# slarson@ncmir.ucsd.edu
# 05/27/07

my $reader = new XML::LibXML::Reader(location => "swanson-98.xml")
    or die "cannot read file.xml\n";

my $dom = XML::LibXML::Document->new();
# create root node
my $root = $dom->createElementNS( "", "Molecules" );
$dom->setDocumentElement( $root );
  
#data structure for keeping track of duplicates
my %visitedHash = ();

while ($reader->read) {
    # for element nodes
    if ($reader->nodeType == 1) {
	# for nodes that talk about molecules
	if ($reader->name =~ /molecule_in_region|molecule_in_cell/) {

	    # pull out id tag and strip out non digit portions
	    my $id = $reader->getAttribute("id");
	    my $numId;
	    if ($id =~ /[A-Za-z](\d+)/) {
		$numId = $1;
	    }

	    #if we have not seen this id before, add it as
	    # an element, and add it to the visitedHash
	    if (!$visitedHash{$numId}) {
		my $node = $root->addNewChild("", "Molecule");
		$node->setAttribute("id",$numId);
		$node->setAttribute("abbrev",$reader->getAttribute("abbreviation"));
		$node->setAttribute("name",$reader->getAttribute("name"));

		$visitedHash{$numId} = $abbrev;
	    }
	}
    }
}

#print the xml file out
my $str = $dom->toStringHTML();
print $str;
