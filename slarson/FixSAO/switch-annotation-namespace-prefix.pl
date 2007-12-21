#!/usr/bin/perl -w


while (<>) {
    if (s/birn_annot/birn_annot_old/g) {}
    if (s/obo_annot:/obo_annot_old:/g){}
    if (s/obo_annot=/obo_annot_old=/g){}
    print STDOUT;
}
