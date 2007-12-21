<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:output method="text" />

<!-- 

Converts an XML file that contains brain part information
into a GraphViz dot file

06/10/07
slarson@ncmir.ucsd.edu

-->

<xsl:template match="/">
<xsl:text>
# source target
</xsl:text>

<xsl:apply-templates mode="getParts"/>

</xsl:template>


<xsl:template match="//Part" mode="getParts">
<xsl:if test="@is_part_of_abbrev">

<xsl:value-of select="translate(@is_part_of_abbrev,'./-() ,','')"/><xsl:text> </xsl:text><xsl:value-of select="translate(@abbrev,'./-() ,','')"/><xsl:text>
</xsl:text>
</xsl:if>
</xsl:template>


</xsl:stylesheet>

