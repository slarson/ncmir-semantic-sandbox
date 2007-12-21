<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">
 
     <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->
     <!--                                                               -->
     <!--                     OWL Genie - OntologyDirectory             -->
     <!--                                                               -->
     <!-- Author: Roger L. Costello                                     -->
     <!--                                                               -->
     <!-- Purpose: The purpose of this named template is to provide a   -->
     <!--          "lookup service".  That is, you pass in a namespace  -->
     <!--          and it will return the name of the OWL document that -->
     <!--          implements that namespace.                           -->
     <!--                                                               -->
     <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->

     <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->
     <!--                                                               -->
     <!-- NOTE: Namespaces MUST END with #                              -->
     <!--                                                               -->
     <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->

    <xsl:template name="getNameOfOntologyDocument">
        <xsl:param name="namespace"/>

        <xsl:choose>
            <xsl:when test="$namespace = 'http://www.xfront.com/owl/ontologies/camera/#'">
                <xsl:text>camera.owl</xsl:text>
            </xsl:when>
            <xsl:when test="$namespace = 'http://www.xfront.com/owl/ontologies/gunLicense/#'">
                <xsl:text>gunLicense.owl</xsl:text>
            </xsl:when>
            <xsl:when test="$namespace = 'http://www.xfront.com/owl/ontologies/water/#'">
                <xsl:text>naturally-occurring.owl</xsl:text>
            </xsl:when>
		<xsl:when test="$namespace = 'http://ccdb.ucsd.edu/SAO/1.0/#'">
                <xsl:text>SAO.owl</xsl:text>
            </xsl:when>

	    <xsl:when test="$namespace = 'http://www.ifomis.org/bfo/1.0/snap#'">
                <xsl:text>BFO.owl</xsl:text>
            </xsl:when>

        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>