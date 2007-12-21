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
digraph brain {
graph[size="8,10", ratio=fill, center=1, nodesep=1.5, ranksep=2.5, rankdir=LR, overlap=false];
  node[fontsize=350];
</xsl:text>

<xsl:apply-templates mode="getParts"/>

<xsl:text>
}
</xsl:text>
</xsl:template>


<xsl:template match="//Part" mode="getParts">
<!-- gives nodes a URL -->
<xsl:value-of select="translate(@abbrev,'./-() ,','')"/> [URL="http://brancusi.usc.edu/bkms/brain/show-braing2.php?aidi=<xsl:value-of select="@id"/>"<xsl:if test="@canonical">, style=filled</xsl:if>];
<xsl:if test="@is_part_of_abbrev">
<xsl:value-of select="translate(@is_part_of_abbrev,'./-() ,','')"/>-><xsl:value-of select="translate(@abbrev,'./-() ,','')"/>;
</xsl:if>
</xsl:template>


</xsl:stylesheet>

