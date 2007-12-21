<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:birn_annot="http://www.nbirn.net/birnlex/1.0/BIRNLex_annotation_properties.owl#"
    xmlns:obo_annot="http://www.nbirn.net/birnlex/1.0/OBO_annotation_properties.owl#"  
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" 
    xmlns:owl="http://www.w3.org/2002/07/owl#" 
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:core="http://www.w3.org/2004/02/skos/core#"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns="http://ccdb.ucsd.edu/SAO/1.2#">

<xsl:output method="xml" />

<!-- 

Several fixes to the ontology file to undo the mangling
it experiences when it emerges from the database.

Strips out the ontologies that are copied in, and 
fixes the bad namespaces that the SAO classes get trapped in.

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

<xsl:variable name="badURI" select="'http://purl.org/dc/elements/1.1/'"/>
<xsl:variable name="bogusBaseURI" select="'http://www.nbirn.net/birnlex/1.0/BIRNLex_annotation_properties.owl#'"/>


<!-- Any first-level owl:Class element with an rdf:about tag -->
<xsl:template match="/rdf:RDF/*[@rdf:about]">
	<xsl:choose>
	<!-- if its rdf:about label begins with the bad URI, replace 
	     its prefix with what follows the bad URI (thus removing the
             bad URI)
	-->
	<xsl:when test="starts-with(@rdf:about,$badURI)">
		<xsl:element name="{name()}" >
			<xsl:attribute name="rdf:about">
				<xsl:text>#</xsl:text><xsl:value-of select="substring-after(@rdf:about,$badURI)"/>
			</xsl:attribute>
			<xsl:apply-templates />
		</xsl:element>
	</xsl:when>
	<!-- get rid of any other tag -->
	</xsl:choose>
</xsl:template>

<!-- any tag with an rdf:about property -->
<!-- replace its bad rdf:about URI with the default or copy the tag -->
<xsl:template match="//*[@rdf:about]" priority="-0.5">
	<xsl:choose>
	<xsl:when test="starts-with(@rdf:about,$badURI)">
		<xsl:element name="{name()}" >
			<xsl:attribute name="rdf:about">
				<xsl:text>#</xsl:text><xsl:value-of select="substring-after(@rdf:about,$badURI)"/>
			</xsl:attribute>
			<xsl:apply-templates />
		</xsl:element>
	</xsl:when>
	<xsl:otherwise>
		<xsl:copy-of select="."/>
	</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="//*[@rdf:resource]" priority="-0.5">
	<xsl:choose>
	<xsl:when test="starts-with(@rdf:resource,$badURI)">
		<xsl:element name="{name()}" >
			<xsl:attribute name="rdf:resource">
				<xsl:text>#</xsl:text><xsl:value-of select="substring-after(@rdf:resource,$badURI)"/>
			</xsl:attribute>
			<xsl:apply-templates />
		</xsl:element>
	</xsl:when>
	<xsl:otherwise>
		<xsl:copy-of select="."/>
	</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- replace dc namespace with sao (default)
     namespace -->
<xsl:template match="//dc:*">
	<xsl:choose>
	<xsl:when test="local-name()!='curationStatus'">
	<xsl:element name="{local-name()}" namespace="http://ccdb.ucsd.edu/SAO/1.2#">
	<xsl:apply-templates />
	</xsl:element>
	</xsl:when>
	<xsl:otherwise>
		<xsl:copy-of select="."/>
	</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- replace (default) namespace with birn_annot namespace -->
<!--
<xsl:template match="//*[namespace-uri()='http://ccdb.ucsd.edu/SAO/1.0']">
	<xsl:element name="birn_annot:{local-name()}">
	<xsl:apply-templates />
	</xsl:element>
</xsl:template>
-->

<!-- get rid of any tags with rdf:ID attributes -->
<xsl:template match="//*[@rdf:ID]">
</xsl:template>

<xsl:template match="//rdf:Property">
</xsl:template>

</xsl:stylesheet>

