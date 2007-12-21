<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:birn_annot_old="http://www.nbirn.net/birnlex/1.0/BIRNLex_annotation_properties.owl#"
    xmlns:obo_annot_old="http://www.nbirn.net/birnlex/1.0/OBO_annotation_properties.owl#"  
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" 
    xmlns:owl="http://www.w3.org/2002/07/owl#" 
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:birn_annot="http://www.nbirn.net/birnlex/1.2.2/BIRNLex_annotation_properties.owl#"
    xmlns:obo_annot="http://www.nbirn.net/birnlex/1.2.2/OBO_annotation_properties.owl#">
  
<!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->
<!--    Translate Birnlex_annotation_properties and     -->
<!--    OBO_annotation_properties from version 1.0      -->
<!--    to version 1.2.2.                               -->

<!--    by Stephen D. Larson (slarson@ncmir.ucsd.edu)   -->
<!--              05/14/07                              -->

<!--    Assumes source owl file has both                -->
<!--    birn_annot_old/obo_annot_old &                  -->
<!--    birn_annot/obo_annot namespaces                 -->
<!--    declared in header.                             -->

<!--    Tested with Xalan XSLT processor                -->
<!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->

<xsl:output method="xml" />

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

<!-- FOR DefinitionSource -->

<xsl:template match="//owl:Class/obo_annot_old:definitionSource">
	<rdfs:subClassOf>
	      <owl:Restriction>
		  <xsl:element name="owl:hasValue">
			<xsl:attribute name="rdf:resource">http://www.nbirn.net/birnlex/1.2.2/OBO_annotation_properties.owl#<xsl:value-of select="."/>_defSource</xsl:attribute>
		  </xsl:element>
                     <owl:onProperty rdf:resource="http://www.nbirn.net/birnlex/1.2.2/OBO_annotation_properties.owl#hasDefinitionSource"/>
              </owl:Restriction>
	</rdfs:subClassOf>
</xsl:template>

<!-- FOR ExternalSource:-->

<xsl:template match="//owl:Class/obo_annot_old:birnlexExternalSource">
	<rdfs:subClassOf>
	      <owl:Restriction>
		  <xsl:element name="owl:hasValue">
			<xsl:attribute name="rdf:resource">http://www.nbirn.net/birnlex/1.2.2/OBO_annotation_properties.owl#<xsl:value-of select="."/></xsl:attribute>
		  </xsl:element>
                  <owl:onProperty rdf:resource="http://www.nbirn.net/birnlex/1.2.2/OBO_annotation_properties.owl#hasExternalSource"/>
              </owl:Restriction>
	</rdfs:subClassOf>
</xsl:template>

<!--
FOR BirnlexExternalSource:

    
NEED to switch the following from BirnlexExternalSource to ExternalSource
		UMLS 
		OBR	
		NCBI Taxonomy	
		MeSH	
		MeSH-UMLS	
		FMA
-->

<xsl:template match="//owl:Class/birn_annot_old:birnlexExternalSource">
	<rdfs:subClassOf>
	      <owl:Restriction>
		  <xsl:element name="owl:hasValue">
		  <xsl:attribute name="rdf:resource">http://www.nbirn.net/birnlex/1.2.2/OBO_annotation_properties.owl#<xsl:value-of select="."/></xsl:attribute>
		  </xsl:element>
	<xsl:choose>
		<xsl:when test=".='UMLS' or .='OBR' or .='NCBI Taxonomy' or .='MeSH' or .='MeSH-UMLS' or .='FMA'">
                  <owl:onProperty rdf:resource="http://www.nbirn.net/birnlex/1.2.2/OBO_annotation_properties.owl#hasExternalSource"/>
		</xsl:when>
		<xsl:otherwise>
                  <owl:onProperty rdf:resource="http://www.nbirn.net/birnlex/1.2.2/BIRNLex_annotation_properties.owl#hasBirnlexExternalSource"/>			
		</xsl:otherwise>
	</xsl:choose>
              </owl:Restriction>
	</rdfs:subClassOf>
</xsl:template>

<!-- FOR CurationStatus -->

<xsl:template match="//owl:Class/birn_annot_old:curationStatus">
	<!-- Make sure there are no strange values -->
	<xsl:if test=".='definition incomplete' or .='curation complete' or .='raw import' or .='graph position temporary' or .='pending final vetting' or .='uncurated'">
	<rdfs:subClassOf>
	      <owl:Restriction>
		  <xsl:element name="owl:hasValue">
			<xsl:attribute name="rdf:resource">http://www.nbirn.net/birnlex/1.2.2/BIRNLex_annotation_properties.owl#<xsl:value-of select="translate(.,' ','_')"/></xsl:attribute>
		  </xsl:element>
                  <owl:onProperty rdf:resource="http://www.nbirn.net/birnlex/1.2.2/BIRNLex_annotation_properties.owl#hasCurationStatus"/>
              </owl:Restriction>
	</rdfs:subClassOf>
	</xsl:if>
</xsl:template>

<!-- FOR birnlexDefinitionSource -->

<xsl:template match="//owl:Class/birn_annot_old:birnlexDefinitionSource">
	<rdfs:subClassOf>
	      <owl:Restriction>
		  <xsl:element name="owl:hasValue">
	<xsl:choose>
		<xsl:when test=".='UMLS' or .='Wikipedia' or .='FMA' or .='OBI' or .='MeSH'">
		  <xsl:attribute name="rdf:resource">http://www.nbirn.net/birnlex/1.2.2/OBO_annotation_properties.owl#<xsl:value-of select="."/>_defSource</xsl:attribute>
		</xsl:when>
		<xsl:when test=".='American Heritage Dictionary, 4th ed'">
		  <xsl:attribute name="rdf:resource">http://www.nbirn.net/birnlex/1.2.2/OBO_annotation_properties.owl#American_Heritage_Dictionary_4th_ed_defSource</xsl:attribute>
		</xsl:when>
		<xsl:when test=".='Merriam-Websters Dictionary, online edition, 2006'">
		  <xsl:attribute name="rdf:resource">http://www.nbirn.net/birnlex/1.2.2/OBO_annotation_properties.owl#Meriam_Websters_Dictionary_online_ed_2006_defSource</xsl:attribute>
		</xsl:when>
		<xsl:when test=".='Stanford Encyclopedia of Philosophy'">
		  <xsl:attribute name="rdf:resource">http://www.nbirn.net/birnlex/1.2.2/OBO_annotation_properties.owl#Stanford_Encyclopedia_of_Philosophy_defSource</xsl:attribute>
		</xsl:when>
		<xsl:when test=".='The Sylvius Project'">
		  <xsl:attribute name="rdf:resource">http://www.nbirn.net/birnlex/1.2.2/OBO_annotation_properties.owl#The_Sylvius_Project_defSource</xsl:attribute>
		</xsl:when>
		<xsl:when test=".='International Mouse Strain Resource Glossary'">
		  <xsl:attribute name="rdf:resource">http://www.nbirn.net/birnlex/1.2.2/OBO_annotation_properties.owl#IMSR_Glossary_defSource</xsl:attribute>
		</xsl:when>
	</xsl:choose>
		  </xsl:element>
                  <owl:onProperty rdf:resource="http://www.nbirn.net/birnlex/1.2.2/OBO_annotation_properties.owl#hasDefinitionSource"/>
              </owl:Restriction>
	</rdfs:subClassOf>
</xsl:template>

<!-- FOR birnlexAbbrevSource -->

<xsl:template match="//owl:Class/birn_annot_old:birnlexAbbrevSource">
	<rdfs:subClassOf>
	      <owl:Restriction>
		  <xsl:element name="owl:hasValue">
			<xsl:attribute name="rdf:resource">http://www.nbirn.net/birnlex/1.2.2/BIRNLex_annotation_properties.owl#<xsl:value-of select="."/>_abbrevSource</xsl:attribute>
		  </xsl:element>
                  <owl:onProperty rdf:resource="http://www.nbirn.net/birnlex/1.2.2/BIRNLex_annotation_properties.owl#hasAbbrevSource"/>
              </owl:Restriction>
	</rdfs:subClassOf>
</xsl:template>


<!-- FOR BIRNLex_annotation_properties:birnlexCurator -->

<xsl:template match="//owl:Class/birn_annot_old:birnlexCurator | //owl:Class/obo_annot_old:birnlexCurator">
	<rdfs:subClassOf>
	      <owl:Restriction>
		  <xsl:element name="owl:hasValue">
			<xsl:attribute name="rdf:resource">http://www.nbirn.net/birnlex/1.2.2/BIRNLex_annotation_properties.owl#<xsl:value-of select="translate(., ' ', '_')"/></xsl:attribute>
		  </xsl:element>
                  <owl:onProperty rdf:resource="http://www.nbirn.net/birnlex/1.2.2/BIRNLex_annotation_properties.owl#hasBirnlexCurator"/>
              </owl:Restriction>
	</rdfs:subClassOf>
	<xsl:element name="dc:contributor">
		<xsl:attribute name="rdf:datatype">xsd:string</xsl:attribute>
	</xsl:element>
</xsl:template>

<!-- FIX non STRING fields -->

<!-- neuronamesID -->
<xsl:template match="//birn_annot_old:neuronamesID">
	<xsl:element name="birn_annot:neuronamesID">
		<xsl:attribute name="rdf:datatype">xsd:string</xsl:attribute>
		<xsl:value-of select="."/>
	</xsl:element>
</xsl:template>

<!-- umlsCUID -->
<xsl:template match="//birn_annot_old:UmlsCui">
	<xsl:element name="obo_annot:UmlsCui">
		<xsl:attribute name="rdf:datatype">xsd:string</xsl:attribute>
		<xsl:value-of select="."/>
	</xsl:element>
</xsl:template>

<!-- bonfireID -->
<xsl:template match="//birn_annot_old:bonfireID">
	<xsl:element name="birn_annot:bonfireID">
		<xsl:attribute name="rdf:datatype">xsd:string</xsl:attribute>
		<xsl:value-of select="."/>
	</xsl:element>
</xsl:template>

<!-- neuroNamesAncillaryTerm -->
<xsl:template match="//birn_annot_old:neuroNamesAncillaryTerm">
	<xsl:element name="birn_annot:neuroNamesAncillaryTerm">
		<xsl:attribute name="rdf:datatype">xsd:string</xsl:attribute>
		<xsl:value-of select="."/>
	</xsl:element>
</xsl:template>

<!-- bams_aidi -->
<xsl:template match="//birn_annot_old:bams_aidi">
	<xsl:element name="birn_annot:bams_aidi">
		<xsl:attribute name="rdf:datatype">xsd:string</xsl:attribute>
		<xsl:value-of select="."/>
	</xsl:element>
</xsl:template>

<!-- createdDate -->

<xsl:template match="//obo_annot_old:createdDate">
	<xsl:element name="obo_annot:createdDate">
		<xsl:attribute name="rdf:datatype">xsd:string</xsl:attribute>
		<xsl:value-of select="."/>
	</xsl:element>
</xsl:template>

<!-- modifiedDate -->

<xsl:template match="//obo_annot_old:modifiedDate">
	<xsl:element name="obo_annot:modifiedDate">
		<xsl:attribute name="rdf:datatype">xsd:string</xsl:attribute>
		<xsl:value-of select="."/>
	</xsl:element>
</xsl:template>

<!-- hasFormerParentClass -->

<xsl:template match="//birn_annot_old:hasFormerParentClass">
	<xsl:element name="birn_annot:hasFormerParentClass">
		<xsl:attribute name="rdf:datatype">xsd:string</xsl:attribute>
		<xsl:value-of select="."/>
	</xsl:element>
</xsl:template>

<!-- currentlyKnownApplicationUses [NOT ACTUALLY IN VERSION 1.2.2 ONLINE!!!]-->
<!--
<xsl:template match="//birn_annot_old:currentlyKnownApplicationUses">
	<rdfs:subClassOf>
	      <owl:Restriction>
		  <xsl:element name="owl:hasValue">
			<xsl:attribute name="rdf:resource">http://www.nbirn.net/birnlex/1.2.2/BIRNLex_annotation_properties.owl#<xsl:value-of select="translate(.,' ','_')"/>_app</xsl:attribute>
		  </xsl:element>
                  <owl:onProperty rdf:resource="http://www.nbirn.net/birnlex/1.2.2/BIRNLex_annotation_properties.owl#hasKnownApplicationUses"/>
              </owl:Restriction>
	</rdfs:subClassOf>
</xsl:template>
-->

<!-- Replace import statement with new version of birnlex -->

<xsl:template match="//owl:imports[@rdf:resource='http://www.nbirn.net/birnlex/1.0/BIRNLex_annotation_properties.owl']">
	<xsl:copy>
		<xsl:attribute name="rdf:resource">
			<xsl:text>http://www.nbirn.net/birnlex/1.2.2/BIRNLex_annotation_properties.owl</xsl:text>
		</xsl:attribute>
	</xsl:copy>
</xsl:template>


<!-- New instance-based annotation properties means
     no support for annotation properties anywhere 
     but in Classes.  Do nothing if they are found 
     elsewhere                
-->
<xsl:template match="//birn_annot_old:curationStatus | //obo_annot_old:definitionSource | //obo_annot_old:birnlexExternalSource | //birn_annot_old:birnlexExternalSource | //birn_annot_old:birnlexDefinitionSource | //birn_annot_old:birnlexAbbrevSource | //birn_annot_old:birnlexCurator | //obo_annot_old:birnlexCurator" priority="-0.3">	
</xsl:template>



<!-- Take care of any leftover obo_annot_old properties -->

<xsl:template match="//obo_annot_old:*" priority="-0.5">
	<xsl:element name="{concat('obo_annot:', local-name())}">
		<xsl:attribute name="rdf:datatype">xsd:string</xsl:attribute>
		<xsl:value-of select="."/>
	</xsl:element>
</xsl:template>

</xsl:stylesheet>

