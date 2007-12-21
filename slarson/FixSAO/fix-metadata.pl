#!/usr/bin/perl -w

print STDOUT '<?xml version="1.0"?>'."\n";
print STDOUT '<rdf:RDF'."\n";
print STDOUT '    xmlns:birn_annot="http://www.nbirn.net/birnlex/1.0/BIRNLex_annotation_properties.owl#"'."\n";
print STDOUT '    xmlns:obo_annot="http://www.nbirn.net/birnlex/1.0/OBO_annotation_properties.owl#"'."\n";
print STDOUT '    xmlns:protege="http://protege.stanford.edu/plugins/owl/protege#"'."\n";
print STDOUT '    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"'."\n";
print STDOUT '    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"'."\n";
print STDOUT '    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"'."\n";
print STDOUT '    xmlns:owl="http://www.w3.org/2002/07/owl#"'."\n";
print STDOUT '    xmlns:bfo="http://www.ifomis.org/bfo/1.0#"'."\n";
print STDOUT '    xmlns:daml="http://www.daml.org/2001/03/daml+oil#"'."\n";
print STDOUT '    xmlns:dc="http://purl.org/dc/elements/1.1/"'."\n";
print STDOUT '    xmlns="http://ccdb.ucsd.edu/SAO/1.2#"'."\n";
print STDOUT '  xml:base="http://ccdb.ucsd.edu/SAO/1.2">'."\n";
print STDOUT '  <owl:Ontology rdf:about="">'."\n";
#print STDOUT '    <owl:imports rdf:resource="http://protege.stanford.edu/plugins/owl/protege"/>'."\n";
## remove for DL comptibility
#print STDOUT '    <owl:imports rdf:resource="http://www.nbirn.net/birnlex/1.0/BIRNLex_annotation_properties.owl"/>'."\n";
print STDOUT '    <owl:versionInfo rdf:datatype="http://www.w3.org/2001/XMLSchema#string"'."\n";
print STDOUT '    >Version 1.2</owl:versionInfo>'."\n";
print STDOUT '    <birn_annot:curationStatus rdf:datatype="http://www.w3.org/2001/XMLSchema#string"'."\n";
print STDOUT '    >uncurated</birn_annot:curationStatus>'."\n";
print STDOUT '    <owl:imports rdf:resource="http://www.ifomis.org/bfo/1.0"/>'."\n";
print STDOUT '    <dc:date rdf:datatype="http://www.w3.org/2001/XMLSchema#string"'."\n";
print STDOUT '    >June 21, 2007</dc:date>'."\n";
#print STDOUT '    <owl:imports rdf:resource="http://protege.stanford.edu/plugins/owl/dc/protege-dc.owl"/>'."\n";
print STDOUT '    <dc:creator rdf:datatype="http://www.w3.org/2001/XMLSchema#string"'."\n";
print STDOUT '    >Maryann Martone, Lisa Fong, Stephen D. Larson, Lily Chen, and Amarnath Gupta</dc:creator>'."\n";
print STDOUT '    <rdfs:comment rdf:datatype="http://www.w3.org/2001/XMLSchema#string"'."\n";
print STDOUT '    >Release Notes:'."\n";
print STDOUT '1.1 - 05/28/2007'."\n";
print STDOUT 'Added definitions'."\n";
print STDOUT 'Modified Non-neuronal cell types, especially glial types'."\n";
print STDOUT 'Simplified properties'."\n";
print STDOUT 'Did a lot of work cleaning up restrictions'."\n";
print STDOUT '1.2'."\n";
print STDOUT 'Restructured cell class hierarchy for glia and epithelial cells</rdfs:comment>'."\n";
print STDOUT '    <dc:subject rdf:datatype="http://www.w3.org/2001/XMLSchema#string"'."\n";
print STDOUT '    >Ontology for the subcellular anatomy of the nervous system</dc:subject>'."\n";
print STDOUT '    <dc:title rdf:datatype="http://www.w3.org/2001/XMLSchema#string"'."\n";
print STDOUT '    >Subcellular Anatomy Ontology (SAO)</dc:title>'."\n";
#print STDOUT '    <owl:imports rdf:resource="http://purl.org/obo/obo-all/ro_bfo_bridge/ro_bfo_bridge.owl"/>'."\n";
print STDOUT '  </owl:Ontology>'."\n";


$toggle = 0;
while (<>) {
    if (/owl:Class/) {
        $toggle = 1;
    }

    if ($toggle) {
        print STDOUT;
    }
}
