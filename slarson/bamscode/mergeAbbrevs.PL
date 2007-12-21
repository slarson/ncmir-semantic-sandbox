#!/usr/bin/perl -w
use strict;

open(IN, "<swanson-98.xml");
open(IN2, "<BAMS.owl");
open(OUT, ">BAMS-fixed.owl");

my %abbrevs = ();
while(<IN>) {
    if (/part \S+ name="(.+)" abbreviation="(.+)" url_base/) {
	$abbrevs{$1} = $2;
    }
}
my $mark = 0;
while(<IN2>) {
    if (/<Full_Name .+>(.+)<\/Full_Name>/) {
	print OUT;
	print OUT "<abbreviation rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">".$abbrevs{$1}."</abbreviation>\n";
    } elsif (/<Full_Name rdf:datatype=\"http:\/\/www.w3.org\/2001\/XMLSchema\#string\"$/) {
	print OUT;
	$mark = 1;
    } elsif ($mark) {
	if (/>(.+)<\/Full_Name>/) {
	    print OUT;
	    my $abbrev = $abbrevs{$1};
	    if (!$abbrev) {
		print "Warning: ".$1."\n";;
	    } else {
		print OUT "<abbreviation rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">".$abbrev."</abbreviation>\n";
	    }
	    $mark = 0;
	} else {
	    print "ERROR\n";
	    print;
	    exit;
	}
    } else {
	print OUT;
    }
}

close OUT;
close IN2;
close IN;
