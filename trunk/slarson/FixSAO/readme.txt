To fix SAO from DB:
cat [input file] | fix-SAO-MAIN.pl > [output file]

To separate out instances in a separate file
cat [input file] | strip-rdfProps.pl | strip-owlOntology.pl | strip-owlProps.pl > [instances file]

To use XSL to fix SAO from DB:

java org.apache.xalan.xslt.Process -IN SAO.owl -XSL Fix-SAO-namespaces.xsl -OUT SAO-fixed.owl
java org.apache.xalan.xslt.Process -IN SAO-fixed.owl -XSL Fix-SAO.xsl -OUT SAO-fixed2.owl 



IF (using XSL to upgrade from BIRNLex 1.0 to 1.2.2) {

cat SAO-fixed3.owl | switch-annotation-namespace-prefix.pl > SAO-fixed4.owl 
java org.apache.xalan.xslt.Process -IN SAO-fixed4.owl -XSL birnlex_annot-1.0-to-1.2.2.xsl -OUT SAO-fixed5.owl

}

cat SAO-fixed2.owl | fix-metadata.pl > SAO-fixed3.owl 
Note: look out for classes that have been converted to type "KB".  Also lookout for URI's that have no '#' where they should be.  Also lookout because the definition annotation property sometimes randomly disappears.  Also look out for the absence of the "description" property.  Also look out for malformed instances... may have to strip them out.

Note2: at one point, it was necessary to, before starting, eliminate the 'KB' from the ontology
java org.apache.xalan.xslt.Process -IN SAO.owl -XSL Fix-SAO-RemoveKB.xsl -OUT SAO-fixed.owl

To update SAO ids and make sure all SAO names are now the ids:

Change name of owl file in update-SAO-ids.pl
run update-SAO-ids.pl > output.owl
notice output to insure sane id additions.. possibly modify output file.
