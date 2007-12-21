#!/usr/bin/perl -w
use strict;

open(IN, "<BAMS.owl");
open(OUT, ">BAMS-graph.dot");
my $insideConnStmnt = 0;
my $insideBP = 0;
my $sending = '';
my $receiving = '';
my %names = ();
my %cnxns = ();
print OUT "digraph brain {\n";
print OUT " size=\"10,10\";\n";
while(<IN>) {
    if ($_ =~ m/Connection_Statement rdf:ID=\"(\S+)\"/) {
	#inside a connection statement
	$insideConnStmnt = 1;
    } elsif ($_ =~ m/\/Connection_Statement/){
	#outside a connection statement
	if ($sending & $receiving) {
	    my $hashRef = $cnxns{$sending};
	    my %hash = ();
	    if ($hashRef) {
		%hash = %$hashRef;
	    } 
	    $hash{$receiving} = 1;
	    $cnxns{$sending} = \%hash;
	}
	$sending = '';
	$receiving = '';
	$insideConnStmnt = 0;
    } elsif ($insideConnStmnt) {
	if ($_ =~ m/sending_Structure rdf:resource=\"\#(\S+)\"/) {
	    $sending = $1;
	    $names{$sending} = 1;
	} elsif ($_ =~ m/receiving_Structure rdf:resource=\"\#(\S+)\"/) {
	    $receiving = $1;
	    $names{$receiving} = 1;
	}
    } 
}
close IN;

open IN2, "<regions.txt";
my @restrictionNames = ();
while(<IN2>) {
    chomp;
    push @restrictionNames, $_;
}
close IN2;

foreach (@restrictionNames) {
    if ($_) {
	my $sending = $_;
	if ($cnxns{$sending}) {
	    print OUT $sending." -> {";
	    foreach (keys(%{$cnxns{$sending}})) {
		if ($_) {
		    print OUT $_."; ";
		}
	    }
	    print OUT "}\n";
	}
    }
}
foreach (keys(%names)) {
    print OUT $_." [label=\"\",shape=circle,height=0.12,width=0.12,fontsize=1]; \n";
}
print OUT "}\n";
close OUT;

