#!/usr/bin/perl -w
use strict;

open(IN, "<BAMS.owl");
open(OUT, ">BAMS-graph3.dot");
my $insideConnStmnt = 0;
my $insideBP = 0;
my $sending = '';
my $receiving = '';
my %names = ();
my %cnxns = ();
print OUT "digraph brain {\n";
print OUT "graph[size=\"20,20\",ratio=fill, center=1, nodesep=1.5, ranksep=2.5,rankdir=LR];\n";
print OUT " node[fontsize=12];\n";

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
open IN3, "<abbrevs.txt";
my %abbrevs = ();
while(<IN3>) {
    if (/(\S+)---(\S+)/) {
	my $brev = $2;
	$brev =~ s/[-.()]/_/g;
	$abbrevs{$1} = $brev;
    }
}
close IN3;

#foreach (@restrictionNames) {
foreach(keys(%cnxns)){
    if ($_) {
	my $sending = $_;
	my $abbrev1 = $abbrevs{$sending};
	if (!$abbrev1) {
	    print "Warning: ".$sending."\n";
	    next;
	}
	print OUT $abbrev1." -> {";
	foreach (keys(%{$cnxns{$sending}})) {
	    if ($_) {
		my $abbrev2 = $abbrevs{$_};
		if (!$abbrev2) {
		    print "Warning: ".$sending."\n";
		    next;
		}
		print OUT $abbrev2."; ";
	    }
	}
	print OUT "}\n";
    }
}
#foreach (keys(%names)) {
#    print OUT $_." [label=\"\",shape=circle,height=0.12,width=0.12,fontsize=1]; \n";
#}
print OUT "}\n";
close OUT;

