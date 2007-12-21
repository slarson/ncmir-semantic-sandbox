#!/usr/bin/perl -w
use strict;

use WWW::Mechanize;
use HTML::TokeParser;

my $agent = WWW::Mechanize->new();
#$agent->get("http://brancusi.usc.edu/bkms/brain/show-braing2.php?aidi=347");
$agent->get("http://brancusi.usc.edu/bkms/brain/show-braing2.php?aidi=23");


my $stream = HTML::TokeParser->new(\$agent->{content});

#getParts($stream);
getProjections(\$agent);

sub getProjections {
    my $agent = ${$_[0]};
    if ($agent->follow_link( text_regex => qr/Efferent projections/)) {
	scrapeProjections(\$agent);
    }
    $agent->back();
    if ($agent->follow_link( text_regex => qr/Afferent projections/)) {
	print "reached\n";
	scrapeProjections(\$agent);
	
    }
}


sub scrapeProjections {
    my $agent = ${$_[0]};
    my $stream = HTML::TokeParser->new(\$agent->{content});
    while (my $tag = $stream->get_tag("script")) {
	my $text = $stream->get_text("/script");

	if ($text =~ /\"(conef-det.php\S*)\"/) {
	    my $agent2 = WWW::Mechanize->new();
	    $agent2->get("http://brancusi.usc.edu/bkms/brain/".$1);
	    my $stream2 = HTML::TokeParser->new(\$agent2->{content});
	    my $listRef = scrapeProjDetails($stream2);
	    
	    $stream2 = HTML::TokeParser->new(\$agent2->{content});
	    my $listRef2 = scrapeRefUrl($stream2);
	    

	}

    }
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
	    push @list, \%data;
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
	$refHash{'has-name'} = $partName;
	push @list, \%refHash;
	print "reference ".$partName.$partUrl."\n";
    }
    return \@list;
}

sub fixUrl {
    if ($_[0]) {
	if ($_[0] !~ /http/) {
	    my $string = "http://brancusi.usc.edu";
	    return $string.$_[0];
	}
	return $_[0];
    }
}
