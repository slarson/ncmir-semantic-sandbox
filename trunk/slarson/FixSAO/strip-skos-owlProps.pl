#!/usr/bin/perl -w

my $toggle = 0;
while (<>) {

    if ($_ =~ /<owl:.*Property rdf:about="(.*)">/) {
	if ($1 =~ /skos/) {
	    $toggle++;
	}
    } elsif ((/<owl:.*Property.*\/>/) & ($toggle > 0)) {
    } elsif ((/<owl:.*Property/) & ($toggle > 0)) {
	$toggle++;
    }
    if ($toggle == 0) {
	print STDOUT;
    }
    if (($_ =~ /<\/owl:.*Property>/) & ($toggle > 0)) {
	$toggle--;
    }
}
