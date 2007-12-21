#!/usr/bin/perl -w

$confusedNamespace = "http://www.w3.org/2004/02/skos/core";

while (<>) {
    if (s/$confusedNamespace\#/\#/) {}
    if (s/core://){}
    print STDOUT;
}
