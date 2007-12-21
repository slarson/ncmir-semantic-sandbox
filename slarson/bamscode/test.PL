#!/usr/bin/perl -w

my %data = (
	 'has-name' => 'Layer 6b(layer 7, subplate, deep cortex, claustral complex)',
	 'has-url' => 'http://brancusi.usc.edu/bkms/brain/show-braing2.php?aidi=777',
	 'has-type' => 'grey matter',
	 'has-parts' => [{'has-name' => 'subplate', 'has-url' => 'www.google.com', 'has-type' => 'grey matter'}, {'has-name' => 'deep cortex', 'has-url' => 'www.google.com', 'has-type' => 'grey matter'}]
	 );
writeDataToFile(\%data);

sub writeDataToFile {
    open(IN, ">instances.owl");
    recurse($_[0]);
    close (IN);
}

sub recurse {
    my %data = %{$_[0]};

    my $parts = $data{'has-parts'};
    foreach (@$parts) {
	recurse($_);
    }
    print IN "<MultiCellular_Complex rdf:ID=\"".nameCleanup($data{'has-name'})."\">\n";
    foreach (@$parts) {
	my $part = $_;
	my %datum = %$part;
	print IN "<has_Anatomical_Component rdf:resource=\"\#".nameCleanup($datum{'has-name'})."\"/>\n";
    }
    print IN "<rdfs:comment rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">BAMS NAME: ".$data{'has-name'}."</rdfs:comment>\n";
    print IN "<rdfs:comment rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">BAMS URL: ".$data{'has-url'}."</rdfs:comment>\n";
    print IN "<rdfs:comment rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">BAMS TYPE: ".$data{'has-type'}."</rdfs:comment>\n";
    print IN "</MultiCellular_Complex>\n";
}

sub nameCleanup {
    my $name = $_[0];

    while ($name =~ m/[,\[\]\(\)]/) {
	$name =~ s/[,\[\]\(\)]//;
    }

    while ($name =~ m/\s+/) {
	$name =~ s/\s/_/;
    }
    return $name;
}
