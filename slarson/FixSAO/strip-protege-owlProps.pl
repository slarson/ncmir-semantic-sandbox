#!/usr/bin/perl -w

my %allowedTerms = ("curationStatus", "1", "birnlexDefinition", "1", "birnlexCurator", "1", "UmlsCui", "1", "neuronamesID", "1", "bonfireID", "1", "birnlexDefinitionSource", "1", "birnlexExternalSource", "1", "birnlexComment", "1", "currentlyKnownApplicationUses", "1");

my $toggle = 0;
while (<>) {

    if ($_ =~ /<owl:.*Property rdf:about="(.*\#(.*))">/) {
	my $extra = $2;
	if ($1 =~ /protege/) {
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
