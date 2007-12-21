#!/usr/bin/perl -w
use strict;

use XML::LibXML::Reader;
use XML::LibXML::XPathContext;
use XML::LibXML;

# Add new unique SAO ids to classes and properties that do not have any
# Designed for output of protege 3.3 beta
#
# USAGE: Change name of file below that is parsed into $doc to input SAO file
#        Pipe output to new version using '> output.owl' after calling.
#
# slarson@ncmir.ucsd.edu
# 07/06/07

my $parser = XML::LibXML->new();

my $doc = $parser->parse_file('SAO-1.2.9.owl');

my $xc = XML::LibXML::XPathContext->new($doc);

# Add ids for properties
my @nodes = $xc->findnodes("/rdf:RDF/*[contains(name(),'Property')]");
foreach my $node (@nodes) {
    my @nodes2 = $node->getChildrenByLocalName("sao_ID");
    my $name = $node->localname;
    my $owlName = $node->getAttribute("rdf:about");
    if (!($owlName)) {
	$owlName= $node->getAttribute("rdf:ID");
    }
    my $saoid = '';
    if ($nodes2[0]) {
	$saoid = $nodes2[0]->textContent;
    }

    if (($saoid eq '') & ($name ne "AnnotationProperty")) {
	my $id = getNewID();
	my $newNode = $node->addNewChild("", "sao_ID");
	$newNode->setAttribute("rdf:datatype","http://www.w3.org/2001/XMLSchema#string");
	$newNode->appendText($id);
	
	print STDERR "Added new id $id to node $name with name $owlName\n";
    }
    #print $node->toString();
}


my $xc2 = XML::LibXML::XPathContext->new($doc);

# Add ids for classes
@nodes = $xc2->findnodes("/rdf:RDF/owl:Class");
foreach my $node (@nodes) {
    my @nodes2 = $node->getChildrenByLocalName("sao_ID");
    my $name = $node->localname;
    my $owlName = $node->getAttribute("rdf:about");
    if (!($owlName)) {
	$owlName= $node->getAttribute("rdf:ID");
    }
    my $saoid = '';
    if ($nodes2[0]) {
	$saoid = $nodes2[0]->textContent;
    }

    if ($saoid eq '') {
	my $id = getNewID();
	my $newNode = $node->addNewChild("", "sao_ID");
	$newNode->setAttribute("rdf:datatype","http://www.w3.org/2001/XMLSchema#string");
	$newNode->appendText($id);
	print STDERR "Added new id $id to node $name with name $owlName\n";
    }
    #print $node->toString();
}

    
#print the xml file out
my $str = $doc->toStringHTML();
print $str;

#look at all the existing IDs and return a new random id
sub getNewID {

    my $xc = XML::LibXML::XPathContext->new($doc);
    
    my @nodes = $xc->findnodes("//sao_ID");
    
    my %ids;
    foreach my $node (@nodes) {
	$ids{$node->textContent} = 1;
    }

    my $rand = "sao".int(rand(10000000000));
    while ($ids{$rand}) {
	$rand = "sao".int(rand(10000000000));
    }
    return $rand;
}
