<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">
 
    <xsl:output method="html"/>

    <xsl:include href="OWL-Genie.xsl"/>

     <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->
     <!--                                                               -->
     <!--               Camera Matcher Application                      -->
     <!--                                                               -->
     <!-- Author: Roger L. Costello                                     -->
     <!--                                                               -->
     <!-- Purpose: The purpose of this XSLT application is to           -->
     <!--          determine if an XML document contains info which     -->
     <!--          meets this desire:                                   -->
     <!--                                                               -->
     <!--            "I am interested in purchasing a camera with a     -->
     <!--             75-300mm zoom lens size, that has an aperture     -->
     <!--             of 4.5-5.6, and a shutter speed that ranges       --> 
     <!--             from 1/500 sec. to 1.0 sec."                      -->
     <!--                                                               -->
     <!--          As an XML document is parsed, this XSLT application  -->
     <!--          "consults" the Camera Ontology, via the collection   -->
     <!--          of XSLT named-templates which I call the OWL-genie   -->
     <!--                                                               -->
     <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->

    <xsl:variable name="NeuronURI" select="'http://ccdb.ucsd.edu/SAO/1.0/#Purkinje_Cell'"/>
    <xsl:variable name="apertureURI" select="'http://www.xfront.com/owl/ontologies/camera/#aperture'"/>
    <xsl:variable name="apertureValue" select="'4.5-5.6'"/>
    <xsl:variable name="sizeURI" select="'http://www.xfront.com/owl/ontologies/camera/#size'"/>
    <xsl:variable name="sizeValue" select="'75-300mm zoom'"/>
    <xsl:variable name="shutter-speedURI" select="'http://www.xfront.com/owl/ontologies/camera/#shutter-speed'"/>
    <xsl:variable name="shutter-speedValue" select="' 0.002 1.0 seconds '"/>

    <xsl:template match="/">
        <HTML>
            <HEAD>
                <TITLE>Want a Neuron</TITLE>
            </HEAD>
            <BODY>
                <h3>I am interested in finding a neuron...
                <p/>
                Checking document ...</h3>
                <p/>
                <xsl:apply-templates select="*" mode="looking-for-neuron"/>
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


	<xsl:variable name="className">
		<xsl:call-template name="getLocalName">
			<xsl:with-param name="URI" select="$NeuronURI"/>
		</xsl:call-template>
	</xsl:variable>
	
    <br/>
	<xsl:value-of select="$className"/>
	<br/>

	<xsl:variable name="namespace">

		<xsl:call-template name="getNamespace">
			<xsl:with-param name="URI" select="$NeuronURI"/>
		</xsl:call-template>
	</xsl:variable>
	
	<xsl:value-of select="$namespace"/>
	
    <xsl:variable name="ontologyDocument">
		<xsl:call-template name="getNameOfOntologyDocument">
			<xsl:with-param name="namespace" select="$namespace"/>
		</xsl:call-template>
	</xsl:variable>
	
	<br/>
	<xsl:value-of select="$ontologyDocument"/>
	
	<xsl:variable name="ontology" select="document($ontologyDocument)"/>
	
	<br/>
	<!--<xsl:value-of select="$ontology"/>-->
	
	
	
        <br/>
        <xsl:value-of select="concat(namespace-uri(.), name(.))"/>
        
        <xsl:choose>
            <xsl:when test="concat(namespace-uri(.), name(.)) = $NeuronURI">
                <xsl:text>It contains info about a neuron!</xsl:text>
                
                <p/>
                <!--<xsl:apply-templates select="*" mode="looking-for-neuron-property"/>
                <p/>
                <xsl:apply-templates select="*" mode="looking-for-size"/>
                <p/>
                <xsl:apply-templates select="*" mode="looking-for-shutter-speed"/>
                <xsl:variable name="neuronContents">
                    <xsl:apply-templates select="*" mode="looking-for-neuron-property"/>
                    <xsl:apply-templates select="*" mode="looking-for-size"/>
                    <xsl:apply-templates select="*" mode="looking-for-shutter-speed"/>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="contains($neuronContents, ':(')">
                        <h3>No Match</h3>
                    </xsl:when>
                    <xsl:otherwise>
                        <h3>It's a Match!</h3>
                    </xsl:otherwise>
                </xsl:choose>-->
            </xsl:when>
            <xsl:otherwise>
                <!--<xsl:variable name="superClasses">
                    <xsl:call-template name="getSuperClasses">
                        <xsl:with-param name="classURI" select="$NeuronURI"/>
                    </xsl:call-template>
                </xsl:variable>


        		<xsl:value-of select="$superClasses"/>-->

                <xsl:choose>
					<xsl:when test="contains($superClasses, $NeuronURI)">
                        <!--<xsl:text>It contains info about a Neuron!</xsl:text>
                        <br/>
                        <xsl:value-of select="name(.)"/><xsl:text> is a type of Neuron!</xsl:text>
                        <p/>
                        <xsl:apply-templates select="*" mode="looking-for-neuron-property"/>
                        <p/>
                        <xsl:apply-templates select="*" mode="looking-for-size"/>
                        <p/>
                        <xsl:apply-templates select="*" mode="looking-for-shutter-speed"/>
                        <xsl:variable name="neuronContents">
                            <xsl:apply-templates select="*" mode="looking-for-neuron-property"/>
                            <xsl:apply-templates select="*" mode="looking-for-size"/>
                            <xsl:apply-templates select="*" mode="looking-for-shutter-speed"/>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="contains($neuronContents, ':(')">
                                <h3>No Match</h3>
                            </xsl:when>
                            <xsl:otherwise>
                                <h3>It's a Match!</h3>
                            </xsl:otherwise>
                        </xsl:choose>-->
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- <xsl:apply-templates select="*/*" mode="looking-for-neuron"/>-->
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>

    <xsl:template match="*" mode="looking-for-neuron-property">
        <xsl:choose>
            <xsl:when test="concat(namespace-uri(.), name(.)) = $apertureURI">
                <xsl:text>It contains info about the Neuron!</xsl:text>
                <br/>
                <xsl:choose>
                    <xsl:when test=".=$apertureValue">
                        <xsl:text>And the aperture value matches!</xsl:text>
                        <p/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>But the aperture value does not match :(</xsl:text>
                        <p/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="equivalentProperties">
                    <xsl:call-template name="getEquivalentProperties">
                        <xsl:with-param name="propertyURI" select="concat(namespace-uri(.), name(.))"/>
                    </xsl:call-template>
                </xsl:variable>

                <xsl:choose>
                    <xsl:when test="contains($equivalentProperties, $apertureURI)">
                        <xsl:text>It contains aperture info!</xsl:text>
                        <br/>
                        <xsl:value-of select="name(.)"/><xsl:text> is synonymous with aperture!</xsl:text>
                        <br/>
                        <xsl:choose>
                            <xsl:when test=".=$apertureValue">
                                <xsl:text>And the aperture value matches!</xsl:text>
                                <p/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>But the aperture value does not match :(</xsl:text>
                                <p/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="*/*" mode="looking-for-neuron-property"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>

<!--
    <xsl:template match="*" mode="looking-for-aperture">
        <xsl:choose>
            <xsl:when test="concat(namespace-uri(.), name(.)) = $apertureURI">
                <xsl:text>It contains info about the aperture!</xsl:text>
                <br/>
                <xsl:choose>
                    <xsl:when test=".=$apertureValue">
                        <xsl:text>And the aperture value matches!</xsl:text>
                        <p/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>But the aperture value does not match :(</xsl:text>
                        <p/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="equivalentProperties">
                    <xsl:call-template name="getEquivalentProperties">
                        <xsl:with-param name="propertyURI" select="concat(namespace-uri(.), name(.))"/>
                    </xsl:call-template>
                </xsl:variable>

                <xsl:choose>
                    <xsl:when test="contains($equivalentProperties, $apertureURI)">
                        <xsl:text>It contains aperture info!</xsl:text>
                        <br/>
                        <xsl:value-of select="name(.)"/><xsl:text> is synonymous with aperture!</xsl:text>
                        <br/>
                        <xsl:choose>
                            <xsl:when test=".=$apertureValue">
                                <xsl:text>And the aperture value matches!</xsl:text>
                                <p/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>But the aperture value does not match :(</xsl:text>
                                <p/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="*/*" mode="looking-for-aperture"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>

    <xsl:template match="*" mode="looking-for-size">
        <xsl:choose>
            <xsl:when test="concat(namespace-uri(.), name(.)) = $sizeURI">
                <xsl:text>It contains info about the size!</xsl:text>
                <br/>
                <xsl:choose>
                    <xsl:when test=".=$sizeValue">
                        <xsl:text>And the size value matches!</xsl:text>
                        <p/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>But the size value does not match :(</xsl:text>
                        <p/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="equivalentProperties">
                    <xsl:call-template name="getEquivalentProperties">
                        <xsl:with-param name="propertyURI" select="concat(namespace-uri(.), name(.))"/>
                    </xsl:call-template>
                </xsl:variable>

                <xsl:choose>
                    <xsl:when test="contains($equivalentProperties, $sizeURI)">
                        <xsl:text>It contains size info!</xsl:text>
                        <br/>
                        <xsl:value-of select="name(.)"/><xsl:text> is synonymous with size!</xsl:text>
                        <br/>
                        <xsl:choose>
                            <xsl:when test=".=$sizeValue">
                                <xsl:text>And the size value matches!</xsl:text>
                                <p/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>But the size value does not match :(</xsl:text>
                                <p/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="*/*" mode="looking-for-size"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="*" mode="looking-for-shutter-speed">
        <xsl:choose>
            <xsl:when test="concat(namespace-uri(.), name(.)) = $shutter-speedURI">
                <xsl:text>It contains info about the shutter-speed!</xsl:text>
                <br/>
                <xsl:choose>
                    <xsl:when test=".=$shutter-speedValue">
                        <xsl:text>And the shutter-speed value matches!</xsl:text>
                        <p/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>But the shutter-speed value does not match :(</xsl:text>
                        <p/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="equivalentProperties">
                    <xsl:call-template name="getEquivalentProperties">
                        <xsl:with-param name="propertyURI" select="concat(namespace-uri(.), name(.))"/>
                    </xsl:call-template>
                </xsl:variable>

                <xsl:choose>
                    <xsl:when test="contains($equivalentProperties, $shutter-speedURI)">
                        <xsl:text>It contains shutter-speed info!</xsl:text>
                        <br/>
                        <xsl:value-of select="name(.)"/><xsl:text> is synonymous with shutter-speed!</xsl:text>
                        <br/>
                        <xsl:choose>
                            <xsl:when test=".=$shutter-speedValue">
                                <xsl:text>And the shutter-speed value matches!</xsl:text>
                                <p/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>But the shutter-speed value does not match :(</xsl:text>
                                <p/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="*/*" mode="looking-for-shutter-speed"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    -->

</xsl:stylesheet>