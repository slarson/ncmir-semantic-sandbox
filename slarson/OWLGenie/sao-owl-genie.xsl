<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
   <xsl:output method="html" />

   <xsl:include href="./OWL-Genie.xsl" />
	
   <!--<xsl:variable name="NeuronURI" select="'http://ccdb.ucsd.edu/SAO/1.0/#Purkinje_Cell'" />-->
   <xsl:variable name="NeuronURI" select="'http://www.ifomis.org/bfo/1.0/snap#Object'" />

   <xsl:template match="/">
      <HTML>
         <HEAD>
            <TITLE>Want a Neuron</TITLE>
         </HEAD>

         <BODY>
            <h3>I am interested in finding a neuron... 
            <p />

            Checking document ...</h3>

            <p />

            <xsl:apply-templates select="*" mode="looking-for-neuron" />
         </BODY>
      </HTML>
   </xsl:template>

   <xsl:template match="*" mode="looking-for-neuron">

    	<xsl:variable name="superClasses">
                    <xsl:call-template name="getSuperClasses">
                        <xsl:with-param name="classURI" select="$NeuronURI"/>
                    </xsl:call-template>
        </xsl:variable>


        <xsl:value-of select="$superClasses"/>

   </xsl:template>
</xsl:stylesheet>

