#!/usr/bin/perl -w

my $pipestring = "| fix-bad-namespace.pl | strip-rdfProps.pl | strip-rdfsclasses.pl | strip-birnlex-owlProps.pl | strip-protege-owlProps.pl | strip-bfo-owlClasses.pl | fix-metadata.pl";

open PIPE, $pipestring;
while (<>) {
    print PIPE;
}
