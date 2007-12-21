#!/usr/bin/perl -w
use strict;

use XML::LibXML::Reader;
use XML::LibXML::XPathContext;
use XML::LibXML;

# Merges info on connections extracted from swanson-98
# with info extracted from the BAMS website (projection strength)
#
#
# slarson@ncmir.ucsd.edu
# 06/09/07

#build up a data structure that has the projection strengths
my %projStrengths = ();
my $reader = new XML::LibXML::Reader(location => "cnxns-with-projStrength.xml");


my @projStrengthArray = ();
my $projStrengthArrayRef = \@projStrengthArray;
my $keyName;
while ($reader->read) {
    if ($reader->nodeType == 1) {
	
	if ($reader->name eq "ConnStrength") {
	    $keyName = $reader->getAttribute("source_id")." ".$reader->getAttribute("target_id");
	    #print "$keyName ";
	    @{$projStrengthArrayRef} = ();
	    
	}
	if ($reader->name eq "projStr") {
	    $reader->read;
	    #print $reader->hasValue;
	    push (@{$projStrengthArrayRef}, $reader->value);
	}
	
    }
    
    if (($reader->nodeType == 15) && ($reader->name eq "ConnStrength")){
	#print "\n";
	$projStrengths{$keyName} = $projStrengthArrayRef;
	my @newArray = ();
	$projStrengthArrayRef = \@newArray;
    }
}

$reader = new XML::LibXML::Reader(location => "cnxns.xml")
     or die "cannot read file.xml\n";

my $dom = XML::LibXML::Document->new();
# create root node
my $root = $dom->createElementNS( "", "Connections" );
$dom->setDocumentElement( $root );

while ($reader->read) {
    # for element nodes
    if (($reader->nodeType ==1) && ($reader->name eq "Connection")) {
	my $keyName = $reader->getAttribute("source_id")." ".$reader->getAttribute("target_id");
	#print "$keyName\n";

	my $name = $reader->getAttribute("name");
	my @names = split(/\_to\_/, $name);
	
	my $node = $reader->copyCurrentNode(1);
	my $node2 = $root->appendChild($node);

	$node2->setAttribute("source_abbrev", $names[0]);
	$node2->setAttribute("target_abbrev", $names[1]);
	
	if ($projStrengths{$keyName}) {
	    my @projStrengthArray = @{$projStrengths{$keyName}};
	    
	    foreach my $projStr (@projStrengthArray) {
		#print "$projStr\n";
		$node->addNewChild("", "projStrength")->appendText($projStr);
	    }
	} else {
	    print STDERR "$keyName is missing from the projection strength data\n";
	}
    }
}
    
#print the xml file out
my $str = $dom->toStringHTML();
print $str;
