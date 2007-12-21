#!/usr/bin/perl -w
use strict;

use XML::LibXML::Reader;
use XML::LibXML::XPathContext;
use XML::LibXML;

# Make the sao_IDs the new names of classes and place the current names
# into rdfs:label properties and core:prefLabel properties
#
# USAGE: Change name of file below that is parsed into $doc to input SAO file
#        Pipe output to new version using '> output.owl' after calling.
#
# slarson@ncmir.ucsd.edu
# 07/06/07

my $parser = XML::LibXML->new();

my $doc = $parser->parse_file('SAO-1.2.9-ids.owl');

my $xc = XML::LibXML::XPathContext->new($doc);

my %namesToIds = ();

# for every node that has an sao_ID field...
my @nodes = $xc->findnodes("//sao:sao_ID");
foreach my $node (@nodes) {
    my $saoid = $node->textContent;

    #...get the parent node of that node...
    my $pNode = $node->parentNode;

    #...replace the parent node's name with the id from the sao_ID field...
       # ( read the tag & set a flag identifying which tag you got )
    my $tagFlag = 1;
    my $owlName = $pNode->getAttribute("rdf:about");
    if (!($owlName)) {
	$owlName= $pNode->getAttribute("rdf:ID");
    } else {
	$tagFlag = 0;
    }
    $owlName =~ s/\#//g;

    if ((!($owlName eq $saoid)) & ($owlName !~ m/sao\d/)) {
	if ($tagFlag) {
	    $pNode->setAttribute("rdf:ID",$saoid);
	    print STDERR "Replaced name $owlName with id $saoid\n";
	} else {
	    $pNode->setAttribute("rdf:about","#$saoid");
	    print STDERR "Replaced name $owlName with id #$saoid\n";
	    }
	
	#... store away the name of the parent node ...
	$namesToIds{$owlName} = $saoid;
	$owlName =~ s/_/ /g;

	#... and write that name as an rdfs:label and a core:prefLabel attribute.
	my $newNode = $pNode->addNewChild("", "rdfs:label");
	$newNode->setAttribute("rdf:datatype","http://www.w3.org/2001/XMLSchema#string");
	$newNode->appendText($owlName);
	
	$newNode = $pNode->addNewChild("", "core:prefLabel");
	$newNode->setAttribute("rdf:datatype","http://www.w3.org/2001/XMLSchema#string");
	$newNode->appendText($owlName);
    }
}

#swap names and ids for any appearances of rdf:ID
my $xc2 = XML::LibXML::XPathContext->new($doc);
@nodes = $xc2->findnodes("//*[@*[namespace-uri()='http://www.w3.org/1999/02/22-rdf-syntax-ns#' and local-name()='ID']]");

foreach my $node (@nodes) {

    my $testname = $node->getAttribute("rdf:ID");
    my $owlName = $node->getAttribute("rdf:ID");
    
    if ($namesToIds{$testname}) {
	$node->setAttribute("rdf:ID",$namesToIds{$testname});
    }
    #print "$owlName\n";
}


#swap names and ids for any appearances of rdf:about
my $xc3 = XML::LibXML::XPathContext->new($doc);
@nodes = $xc3->findnodes("//*[@*[namespace-uri()='http://www.w3.org/1999/02/22-rdf-syntax-ns#' and local-name()='about']]");

foreach my $node (@nodes) {

    my $owlName = $node->getAttribute("rdf:about");
    
    my $testname = $owlName;
    $testname =~ s/\#//g;
    
    if ($namesToIds{$testname}) {
	$node->setAttribute("rdf:about","#$namesToIds{$testname}");
    }

    #print "$owlName\n";
}

#swap names and ids for any appearances of rdf:resource
my $xc4 = XML::LibXML::XPathContext->new($doc);
@nodes = $xc4->findnodes("//*[@*[namespace-uri()='http://www.w3.org/1999/02/22-rdf-syntax-ns#' and local-name()='resource']]");

foreach my $node (@nodes) {

    my $owlName = $node->getAttribute("rdf:resource");
    
    my $testname = $owlName;
    $testname =~ s/\#//g;
    
    if ($namesToIds{$testname}) {
	$node->setAttribute("rdf:resource","#$namesToIds{$testname}");
    }

    #print "$owlName\n";
}


my $xc5 = XML::LibXML::XPathContext->new($doc);
@nodes = $xc5->findnodes("//*");

foreach my $node (@nodes) {

    my $owlName = $node->nodeName;
    
    my $testname = $owlName;
    $testname =~ s/\#//g;
    
    if ($namesToIds{$testname}) {
	$node->setNodeName("$namesToIds{$testname}");
    }

    #print "$owlName\n";
}

    
#print the xml file out
my $str = $doc->toStringHTML();
print $str;

