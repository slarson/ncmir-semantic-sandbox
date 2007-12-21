<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:output method="text" />

<!-- 

Converts an XML file that contains brain connectivity data
to a GraphViz dot file to enable graphing.

06/10/07
slarson@ncmir.ucsd.edu

-->


<xsl:template match="/">
<xsl:text>
graph brain {
<!--digraph brain { -->
<!-- graph[size="8,10", ratio=fill, center=1, nodesep=1.5, ranksep=2.5, rankdir=LR, overlap=false];-->
 graph[size="20,20", overlap=false, splines=true];
<!--  node[fontsize=350];-->
</xsl:text>

<xsl:apply-templates mode="getCnxns"/>

<xsl:text>
}
</xsl:text>
</xsl:template>


<xsl:template match="//Connection/projStrength" mode="getCnxns">
<xsl:value-of select="translate(../@source_abbrev,'./-() ,','')"/>-><xsl:value-of select="translate(../@target_abbrev,'./-() ,','')"/> [ label = "<xsl:value-of select="."/>" ];
</xsl:template>

</xsl:stylesheet>

