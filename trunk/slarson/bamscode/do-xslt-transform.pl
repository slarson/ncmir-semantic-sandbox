#!/usr/bin/perl -w
use strict; 

use XML::LibXSLT;
use XML::LibXML;

# Process XSLT transform
#
# slarson@ncmir.ucsd.edu
# 10/29/07


my $parser = XML::LibXML->new();
my $xslt = XML::LibXSLT->new ();

my $source = $parser->parse_file($ARGV[1]);
my $style_doc = $parser->parse_file($ARGV[0]);

my $stylesheet = $xslt->parse_stylesheet($style_doc);

my $results = $stylesheet->transform($source);

print $stylesheet->output_string($results);
