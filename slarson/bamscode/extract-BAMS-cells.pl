#!/usr/bin/perl -w


use XML::LibXML::Reader;
use XML::LibXML;

# Separate out cell tags from swanson-98.xml into a separate file
# that just collects information on the cells.
# Throw away duplicates.
#
# slarson@ncmir.ucsd.edu
# 05/27/07

my $reader = new XML::LibXML::Reader(location => "swanson-98.xml")
    or die "cannot read file.xml\n";

my $dom = XML::LibXML::Document->new();
# create root node
my $root = $dom->createElementNS( "", "Cells" );
$dom->setDocumentElement( $root );
  
#data structure for keeping track of duplicates
my %visitedHash = ();

while ($reader->read) {
    # for element nodes
    if ($reader->nodeType == 1) {
	# for nodes that talk about molecules
	if ($reader->name eq "cell") {

	    # pull out id tag and strip out non digit portions
	    my $id = $reader->getAttribute("id");
	    my $numId = 0;
	    if ($id =~ /[A-Za-z](\d+)/) {
		$numId = $1;
	    }

	    #if we have not seen this id before, add it as
	    # an element, and add it to the visitedHash
	    if (!$visitedHash{$numId}) {
		my $node = $root->addNewChild("", "Cell");
		$node->setAttribute("id",$numId);
		$node->setAttribute("name",$reader->getAttribute("name"));

		$visitedHash{$numId} = $id;
	    }
	}
    }
}

#print the xml file out
my $str = $dom->toStringHTML();
print $str;
