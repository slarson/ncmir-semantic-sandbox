#!/usr/bin/perl -w
use strict;

open(IN, "<BAMS.owl");
open(OUT, ">BAMS-fixed.owl");

while(<IN>) {
    if (/BAMS PROJ STRENGTH: (.+)</) {
	print OUT "<projection_Strength rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">".$1."</projection_Strength>\n";
    } elsif (/BAMS CONN TYPE: (.+)</) {
	print OUT "<connection_Type rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">".$1."</connection_Type>\n";
    } elsif (/BAMS URL: (\S+)</) {
	print OUT "<URL rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">".$1."</URL>\n";
    } elsif (/BAMS NAME: (.+)</) {
	print OUT "<Full_Name rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">".$1."</Full_Name>\n";
    } elsif (/BAMS TYPE: (.+)</) {
	print OUT "<Structure_Type rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">".$1."</Structure_Type>\n";
    } elsif (/BAMS REF URL: (.*)</) {
	if ($1) {
	    print OUT "<Reference_URL rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">".$1."</Reference_URL>\n";
	}
    } else {
	print OUT;
    }
}

close OUT;
close IN;
