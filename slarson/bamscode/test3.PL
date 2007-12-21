#!/usr/bin/perl -w

open(IN, "<instances.owl");
open(OUT, ">instances-fixed.owl");
my $i = 0;
my %dupeHash = ();
while(<IN>) {
    #print OUT fixUrl2($_);
    if ($_ =~ m/Connection_Statement rdf:ID=\"(\S+)\"/) {
	if ($dupeHash{$1}) {
	    print "found dupe: ".$1." \n";
	    $i++;
	} else {
	    $dupeHash{$1} = 1;
	}
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
	$url =~ s/\&/\&amp\;/g;	
	$url =~ s/!!!!!/\&amp;/g;
	return $url
    }
}

sub findDupes{
    if ($_[0] =~ m/Connection_Statement rdf:ID=\"(\S+)\"/) {
	print $1."\n";
	return 1;
    }
    return 0;
}
