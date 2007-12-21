#!/usr/bin/perl -w
use strict;

use WWW::Mechanize;
use HTML::TokeParser;

my $agent = WWW::Mechanize->new();
my $startingURL = "http://brancusi.usc.edu/bkms/brain/show-braing2.php?aidi=23";
$agent->get($startingURL);
#$agent->get("http://www.temet-nosce.net/slarson/show-braing2.php.htm");
#$agent->get("http://www.temet-nosce.net/slarson/show-braing3.php.htm");
#$agent->follow("Cerebrum");

my $stream = HTML::TokeParser->new(\$agent->{content});

my %data = %{spiderBAMSParts($stream, 0)};
$data{'has-name'} = "Cerebellum";
$data{'has-url'} = $startingURL;
$data{'has-type'} = "gray matter";
writeDataToFile(\%data);

sub spiderBAMSParts {
    #if ($_[1] > 1) {
    #    return ();
    #}
    my $count = $_[1] + 1;
    my $stream = $_[0];
    my %data = ();
    
    my $agent2 = $agent->clone();
    $data{'has-projections'} = getProjections(\$agent2);
    my $parts = getParts($stream);
    my @completeParts = ();
    foreach (@$parts) {
	my %datum = %$_;
	my $nameToFollow = $datum{'has-name'};
	print "Now Following: ".$nameToFollow."\n";
	my $urlToFollow = $datum{'has-url'};
	$agent->get($urlToFollow);
	$stream = HTML::TokeParser->new(\$agent->{content});
	sleep 2;
	my %completeDatum = %datum;
	my $dataRef = spiderBAMSParts($stream, $count);
	if ($dataRef) {
	    my %dataHash = %$dataRef;
	    $completeDatum{'has-parts'} = $dataHash{'has-parts'};
	    $completeDatum{'has-projections'} = $dataHash{'has-projections'};
	}
	push @completeParts, \%completeDatum;
    }
    $data{'has-parts'} = \@completeParts;
    print "Complete Parts: ".@completeParts."\n";
    return \%data;
}

sub getParts {
    my $stream = $_[0];
    while (my $tag = $stream->get_tag("table")) {
	
	# Are we inside a subparts table?
	my $tag2 = $stream->get_tag;
	
	if ($tag2->[0] =~ /tbody/) {
	    $tag2 = $stream->get_tag;
	}
	
	if ($tag2->[0] =~ /tr/) {
	    $tag2 = $stream->get_tag;
	}
	
	my $text = $stream->get_text;
	if ($text =~ /Part/) {
	    return scrapePartsTable($stream);
	}
    }
}

sub scrapePartsTable {
    my $stream = $_[0];
    my @parts = ();
    # if so, let's extract the part information and URLs to other pages
    while (my $tag2 = $stream->get_tag("a")) {
	my $partUrl = $tag2->[1]{href};
	my $partName = $stream->get_text("/a");
	
	if ($partName =~ /Brain/){
	    last;
	}

	$tag2 = $stream->get_tag("th");
	my $partType = $stream->get_text("/th");
	
	my %datum;
	$datum{'has-url'} = fixUrl($partUrl);
	$datum{'has-name'} = $partName;
	$datum{'has-type'} = $partType;
	push @parts, \%datum;

	print "Part URL: ".fixUrl($partUrl)."\n  Part Name: ".$partName."\n  Part Type: ".$partType."\n";

    }
    return \@parts;
}

sub writeDataToFile {
    open(IN, ">>instances4.owl");
    recurse($_[0]);
    close (IN);
}

sub recurse {
    if (my %data = %{$_[0]}) {

	my $parts = $data{'has-parts'};
	foreach (@$parts) {
	    recurse($_);
	}
	if (my $name = $data{'has-name'}) {
	    print IN "<MultiCellular_Complex rdf:ID=\"".nameCleanup($name)."\">\n";
	}
	foreach (@$parts) {
	    my $part = $_;
	    my %datum = %$part;
	    print IN "<has_Anatomical_Component rdf:resource=\"\#".nameCleanup($datum{'has-name'})."\"/>\n";
	}
	if ($data{'has-name'}) {
	    print IN "<rdfs:comment rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">BAMS NAME: ".$data{'has-name'}."</rdfs:comment>\n";
	}
	if ($data{'has-url'}) {
	    print IN "<rdfs:comment rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">BAMS URL: ".fixUrl2($data{'has-url'})."</rdfs:comment>\n";
	}
	if ($data{'has-type'}) {
	    print IN "<rdfs:comment rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">BAMS TYPE: ".$data{'has-type'}."</rdfs:comment>\n";
	}
	print IN "</MultiCellular_Complex>\n";
	
	if (my $projections = $data{'has-projections'}) {
	    my %projHash = %$projections;
	    if (my $efProj = $projHash{'has-efferent-projections'}) {
		printProjections($efProj);
		
	    }
	    if (my $afProj = $projHash{'has-afferent-projections'}) {
		printProjections($afProj);
	    }
	}
    }
}

sub printProjections {
    my $efProj = $_[0];
    foreach (@$efProj) {
	my %datumHash = %$_;
	my @projDetails = @{$datumHash{'has-proj-details'}};
	my @projRefs = @{$datumHash{'has-proj-refs'}};
	if (@projDetails != @projRefs) {
	    print "NON MATCHING DETAILS AND REFS COUNT!!";
	}
	my $projUrl = $datumHash{'has-proj-url'};
	my $lengthOfProjDetails = scalar(@projDetails);
	for (my $i = 0; ($i < $lengthOfProjDetails); $i++) {
	    my $sendingStruct = $projDetails[$i]{'has-sending-structure'};
	    my $receivingStruct = $projDetails[$i]{'has-receiving-structure'};
	    my $connType = $projDetails[$i]{'has-connection-type'};
	    my $projStrength = $projDetails[$i]{'has-projection-strength'};
	    my $refName = $projRefs[$i]{'has-name'};
	    my $refUrl = $projRefs[$i]{'has-url'};
	    
	    print IN "<Connection_Statement rdf:ID=\"".nameCleanup($sendingStruct)."_".nameCleanup($receivingStruct)."_".$i."\">\n";
	    print IN "<sending_Structure rdf:resource=\"\#".nameCleanup($sendingStruct)."\"/>\n";
	    print IN "<receiving_Structure rdf:resource=\"\#".nameCleanup($receivingStruct)."\"/>\n";
	    print IN "<reference rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">".nameCleanup($refName)."</reference>\n";
	    print IN "<rdfs:comment rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">BAMS PROJ STRENGTH: ".$projStrength."</rdfs:comment>\n";
	    print IN "<rdfs:comment rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">BAMS CONN TYPE: ".$connType."</rdfs:comment>\n";
	    print IN "<rdfs:comment rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">BAMS URL: ".fixUrl2($projUrl)."</rdfs:comment>\n";
	    print IN "<rdfs:comment rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">BAMS REF URL: ".fixUrl2($refUrl)."</rdfs:comment>\n";
	    print IN "</Connection_Statement>\n";
	}
    }
}


sub nameCleanup {
    if ($_[0]) {
	my $name = $_[0];
	
	while ($name =~ m/[,\[\]\(\)]/) {
	    $name =~ s/[,\[\]\(\)]//;
	}
	
	while ($name =~ m/\s+/) {
	    $name =~ s/\s/_/;
	}
	return $name;
    }
}

#url is not always global.. add back in if missing
sub fixUrl {
    if ($_[0]) {
	if ($_[0] !~ /http/) {
	    my $string = "http://brancusi.usc.edu";
	    return $string.$_[0];
	}
	return $_[0];
    }
}

#encode ampersands
sub fixUrl2 {
    if ($_[0]) {
	my $url = $_[0];
	$url =~ s/\&/\&amp\;/g;	
	$url =~ s/\n//g;	
	$url =~ s/\t//g;	
	return $url
    }
}


#follow the links about projections on each page
# and grab the details.
sub getProjections {
    my $agent = ${$_[0]};
    my %data = ();
    my $efProjData;
    my $afProjData;
    if ($agent->follow_link( text_regex => qr/Efferent projections/)) {
	print "following efferent projections link\n";
	$data{'has-efferent-projections'} = scrapeProjections(\$agent);
	$agent->back();
    }

    if ($agent->follow_link( text_regex => qr/Afferent projections/)) {	
	print "following afferent projections link\n";
	$data{'has-afferent-projections'} = scrapeProjections(\$agent);
	$agent->back();
    }
    return \%data;
}


sub scrapeProjections {
    my $agent = ${$_[0]};
    my $stream = HTML::TokeParser->new(\$agent->{content});
    my @projData = ();
    #iterate through 'script' tags
    print "getting projections...\n";
    while (my $tag = $stream->get_tag("script")) {
	my $text = $stream->get_text("/script");

	#follow links to conef-det.php to the info
	if ($text =~ /\"(conef-det.php\S*)\"/) {
	    my $agent2 = WWW::Mechanize->new();
	    my $projUrl = "http://brancusi.usc.edu/bkms/brain/".$1;
	    $agent2->get($projUrl);

	    #parse info on the connectivity
	    # one list item per row of connectivity info
	    my $stream2 = HTML::TokeParser->new(\$agent2->{content});
	    my $listRef = scrapeProjDetails($stream2);
	    
	    #parse info on the references.
	    # one list item per row of connectivity info
	    $stream2 = HTML::TokeParser->new(\$agent2->{content});
	    my $listRef2 = scrapeRefUrl($stream2);
	    my %refInfo = ();
	    $refInfo{'has-proj-details'} = $listRef;
	    $refInfo{'has-proj-refs'} = $listRef2;
	    $refInfo{'has-proj-url'} = $projUrl;
	    push @projData, \%refInfo;
	    sleep 1;
	}
    }
    return \@projData;
}

# returns a list of projection details from conef-det.php
sub scrapeProjDetails {
    my $stream = $_[0];
    my @list = ();
    my %data = ();
    my $i = 0;
    while ($stream->get_tag("td")) {

	my $text = $stream->get_text("/td");
	if ($i == 8) {
	    $data{'has-sending-structure'} = $text;
	    print "s: ".$text."\n";
	} elsif ($i == 9) {
	    $data{'has-receiving-structure'} = $text;
	    print "r: ".$text."\n";
	} elsif ($i == 10) {
	    $data{'has-projection-strength'} = $text;
	    print "p: ".$text."\n";
	} elsif ($i == 11) {
	    $data{'has-connection-type'} = $text;
	    print "c: ".$text."\n";
	}
	$i++;
	if ($i >= 16 ) {
	    $i = 8;
	    my %dataCopy = %data;
	    push @list, \%dataCopy;
	    %data = ();
	}
    }
    return \@list;
}

sub scrapeRefUrl {
    my $stream = $_[0];
    my @list = ();
    while (my $tag = $stream->get_tag("a")) {
	my $partUrl = $tag->[1]{href};
	my $partName = $stream->get_text("/a");
	
	my %refHash = ();
	$refHash{'has-url'} = $partUrl;
	$refHash{'has-name'} = fixUrl2($partName);
	push @list, \%refHash;
	#print "reference ".$partName.$partUrl."\n";
    }
    return \@list;
}
