<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:sao="http://ccdb.ucsd.edu/SAO/1.1#" xmlns="http://ccdb.ucsd.edu/BAMS/brainparts#">

<xsl:output method="xml" indent="yes"/>

<!-- 

Converts an xml file with information about brainparts from BAMS
into an OWL ontology

06/19/07
slarson@ncmir.ucsd.edu

-->

<xsl:template match="/">
<xsl:element name="rdf:RDF">
 <xsl:attribute name="xml:base">http://ccdb.ucsd.edu/BAMS/brainparts</xsl:attribute>
 <xsl:element name="owl:Ontology">
  <xsl:attribute name="rdf:about"/>
   <xsl:element name="owl:imports">
   <xsl:attribute name="rdf:resource">http://ccdb.ucsd.edu/BAMS/cells</xsl:attribute>
  </xsl:element>
   <xsl:element name="owl:imports">
   <xsl:attribute name="rdf:resource">http://ccdb.ucsd.edu/BAMS/molecules</xsl:attribute>
  </xsl:element>
 </xsl:element>

<xsl:apply-templates mode="getParts"/>

 <xsl:element name="owl:AnnotationProperty">
  <xsl:attribute name="rdf:ID">bams_part_id</xsl:attribute>
 </xsl:element>

 <xsl:element name="owl:ObjectProperty">
  <xsl:attribute name="rdf:ID">contains_cell</xsl:attribute>
 </xsl:element>

 <xsl:element name="owl:ObjectProperty">
  <xsl:attribute name="rdf:ID">contains_molecule</xsl:attribute>
 </xsl:element>


 <xsl:element name="owl:Class">
  <xsl:attribute name="rdf:ID">BrainPart</xsl:attribute>
  <xsl:element name="rdfs:subClassOf">
   <xsl:attribute name="rdf:resource">http://www.ifomis.org/bfo/1.0/snap#ObjectAggregate</xsl:attribute>
  </xsl:element>
 </xsl:element>

</xsl:element>

</xsl:template>


<xsl:template match="//Part" mode="getParts">

<xsl:element name="owl:Class">
 <xsl:attribute name="rdf:ID"><xsl:value-of select="translate(@name,' ()-,','_')"/></xsl:attribute>

  <xsl:element name="rdfs:subClassOf">
  <xsl:attribute name="rdf:resource">#BrainPart</xsl:attribute>
 </xsl:element>

 <xsl:element name="rdfs:label">
  <xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#string</xsl:attribute>
  <xsl:value-of select="@name"/>
 </xsl:element>

 <xsl:element name="bams_part_id">
  <xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#string</xsl:attribute>
  <xsl:value-of select="@id"/>
 </xsl:element>

 <!-- Create universal restrictions to indicate that the individuals
      of this class only contain the cells that are associated with them
 -->
 <xsl:if test="Cells">
 <xsl:element name="rdfs:subClassOf">
  <xsl:element name="owl:Restriction">
   <xsl:element name="owl:allValuesFrom">
    <xsl:element name="owl:Class">
     <xsl:element name="owl:unionOf">
      <xsl:attribute name="rdf:parseType">Collection</xsl:attribute>
      <xsl:apply-templates mode="getCellsAll"/>
     </xsl:element>
    </xsl:element>
   </xsl:element>
   <xsl:element name="owl:onProperty">
    <xsl:attribute name="rdf:resource">#contains_cell</xsl:attribute>
   </xsl:element>
  </xsl:element>
 </xsl:element>
 </xsl:if>

 <!-- Create exisential restrictions to indicate that the individuals
      of this class contain some of the cells that are associated with 
      them
 -->
 <xsl:apply-templates mode="getCellsSome"/>

 <!-- Create universal restrictions to indicate that the individuals
      of this class only contain the molecules that are associated with them
 -->
 <xsl:if test="Molecules">
 <xsl:element name="rdfs:subClassOf">
  <xsl:element name="owl:Restriction">
   <xsl:element name="owl:allValuesFrom">
    <xsl:element name="owl:Class">
     <xsl:element name="owl:unionOf">
      <xsl:attribute name="rdf:parseType">Collection</xsl:attribute>
      <xsl:apply-templates mode="getMolsAll"/>
     </xsl:element>
    </xsl:element>
   </xsl:element>
   <xsl:element name="owl:onProperty">
    <xsl:attribute name="rdf:resource">#contains_molecule</xsl:attribute>
   </xsl:element>
  </xsl:element>
 </xsl:element>
 </xsl:if>

 <!-- Create exisential restrictions to indicate that the individuals
      of this class contain some of the molecules that are associated with 
      them
 -->
 <xsl:apply-templates mode="getMolsSome"/>



</xsl:element>

</xsl:template>

<xsl:template match="Cell" mode="getCellsAll">
      <xsl:element name="owl:Class">
       <xsl:attribute name="rdf:about">http://ccdb.ucsd.edu/BAMS/cells#<xsl:value-of select="@ontology_name"/></xsl:attribute>
      </xsl:element>
</xsl:template>

<xsl:template match="Cell" mode="getCellsSome">
 <xsl:element name="rdfs:subClassOf">
  <xsl:element name="owl:Restriction">
   <xsl:element name="owl:someValuesFrom">
    <xsl:attribute name="rdf:resource">http://ccdb.ucsd.edu/BAMS/cells#<xsl:value-of select="@ontology_name"/></xsl:attribute>
   </xsl:element>
   <xsl:element name="owl:onProperty">
    <xsl:attribute name="rdf:resource">#contains_cell</xsl:attribute>
   </xsl:element>
  </xsl:element>
 </xsl:element>

</xsl:template>

<xsl:template match="Molecule" mode="getMolsAll">
      <xsl:element name="owl:Class">
       <xsl:attribute name="rdf:about">http://ccdb.ucsd.edu/BAMS/molecules#<xsl:value-of select="@ontology_name"/></xsl:attribute>
      </xsl:element>
</xsl:template>

<xsl:template match="Molecule" mode="getMolsSome">
 <xsl:element name="rdfs:subClassOf">
  <xsl:element name="owl:Restriction">
   <xsl:element name="owl:someValuesFrom">
    <xsl:attribute name="rdf:resource">http://ccdb.ucsd.edu/BAMS/molecules#<xsl:value-of select="@ontology_name"/></xsl:attribute>
   </xsl:element>
   <xsl:element name="owl:onProperty">
    <xsl:attribute name="rdf:resource">#contains_molecule</xsl:attribute>
   </xsl:element>
  </xsl:element>
 </xsl:element>

</xsl:template>


</xsl:stylesheet>

