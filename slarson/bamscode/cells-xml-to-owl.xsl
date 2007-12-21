<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:sao="http://ccdb.ucsd.edu/SAO/1.1#" xmlns="http://ccdb.ucsd.edu/BAMS/cells#">

<xsl:output method="xml" indent="yes"/>

<!-- 

Converts an xml file with information about cells from BAMS
into an OWL ontology

06/18/07
slarson@ncmir.ucsd.edu

-->

<xsl:template match="/">
<xsl:element name="rdf:RDF">
 <xsl:attribute name="xml:base">http://ccdb.ucsd.edu/BAMS/cells</xsl:attribute>
 <xsl:element name="owl:Ontology">
  <xsl:attribute name="rdf:about"/>
  <xsl:element name="owl:imports">
   <xsl:attribute name="rdf:resource">http://ccdb.ucsd.edu/SAO/1.1/SAO.owl</xsl:attribute>
  </xsl:element>
 </xsl:element>

<xsl:apply-templates mode="getCells"/>

 <xsl:element name="owl:AnnotationProperty">
  <xsl:attribute name="rdf:ID">bams_cell_id</xsl:attribute>
 </xsl:element>

</xsl:element>

</xsl:template>


<xsl:template match="//Cell" mode="getCells">

<xsl:element name="owl:Class">
 <xsl:attribute name="rdf:ID"><xsl:value-of select="translate(@name,' ()-,/','___')"/></xsl:attribute>

 <xsl:element name="rdfs:subClassOf">
  <xsl:attribute name="rdf:resource">http://ccdb.ucsd.edu/SAO/1.1#Neuron</xsl:attribute>
 </xsl:element>

 <xsl:element name="rdfs:label">
  <xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#string</xsl:attribute>
  <xsl:value-of select="@name"/>
 </xsl:element>

 <xsl:element name="bams_cell_id">
  <xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#string</xsl:attribute>
  <xsl:value-of select="@id"/>
 </xsl:element>

</xsl:element>


</xsl:template>


</xsl:stylesheet>

