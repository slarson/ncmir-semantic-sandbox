#!/usr/bin/perl -w

#######
# Removes all duplicate Connection_Statement blocks
######

open(IN, "<instances.owl");
open(OUT, ">instances-fixed.owl");
my $i = 0;
my %dupeHash = ();
my $withinDupeBlock = 0;
print "printing all lines that are deleted\n";
while(<IN>) {
    #print OUT fixUrl2($_);
    if ($_ =~ m/Connection_Statement rdf:ID=\"(\S+)\"/) {
	if ($dupeHash{$1}) {
	    $i++;
	    $withinDupeBlock = 1;
	    print $_;
	} else {
	    $dupeHash{$1} = 1;
	    $withinDupeBlock = 0;
	    print OUT fixUrl2($_);
	}
    } elsif ($_ =~ m/\/Connection_Statement/){
	if ($withinDupeBlock == 1) {
	    $withinDupeBlock = 0;
	} else {
	    print OUT fixUrl2($_);
	}
    } elsif ($withinDupeBlock == 1) {
	print $_;
    } else {
	print OUT fixUrl2($_);
    }
}
print "found ".$i." duplicate connection statements\n";
close IN;
close OUT;


#encode ampersands
sub fixUrl2 {
    if ($_[0]) {
	$url = $_[0];
	$url =~ s/\&amp;/!!!!!/g;
	$url =~ s/&/\&amp\;/g;	
	$url =~ s/!!!!!/\&amp;/g;
	return $url
    }
}
