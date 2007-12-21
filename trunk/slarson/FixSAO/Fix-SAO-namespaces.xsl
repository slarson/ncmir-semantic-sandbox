<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:birn_annot="http://www.nbirn.net/birnlex/1.0/BIRNLex_annotation_properties.owl#"
    xmlns:obo_annot="http://www.nbirn.net/birnlex/1.0/OBO_annotation_properties.owl#"  
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" 
    xmlns:owl="http://www.w3.org/2002/07/owl#" 
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:core="http://www.w3.org/2004/02/skos/core#"
    xmlns:protege="http://protege.stanford.edu/plugins/owl/protege#"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns="http://ccdb.ucsd.edu/SAO/1.0#">

<xsl:output method="xml" />


<!-- 

Copies the ontology, adding the namespace "http://ccdb.ucsd.edu/SAO/1.2"
to each node in the ontology, making it the default namespace.

This fixes the problem that the DB output seems to lose the base
namespace for all the nodes.

05/16/07
slarson@ncmir.ucsd.edu

-->

<!-- BEGIN IDENTITY TRANSFORM -->
<!-- Copy all nodes that aren't addressed by templates below -->

<xsl:template match="*">
  <xsl:copy>
    <xsl:apply-templates select="@*" />
    <xsl:apply-templates />
  </xsl:copy>
</xsl:template>

<xsl:template match="@*">
  <xsl:copy-of select="." />
</xsl:template>

<!-- END IDENTITY TRANSFORM -->


<xsl:template match="*">
<xsl:element name="{name()}" xmlns="http://ccdb.ucsd.edu/SAO/1.2#">
<xsl:copy-of select="@*" />
<xsl:apply-templates/>
</xsl:element>

</xsl:template>

</xsl:stylesheet>

