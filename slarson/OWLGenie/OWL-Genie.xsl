<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:owl="http://www.w3.org/2002/07/owl#"
                version="1.0">
 
    <xsl:include href="OntologyDirectory.xsl"/>
    <xsl:include href="Private.xsl"/>

     <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->
     <!--                                                               -->
     <!--                     OWL Genie                                 -->
     <!--                                                               -->
     <!-- Author: Roger L. Costello                                     -->
     <!--                                                               -->
     <!-- Purpose: The purpose of this collection of XSLT named         -->
     <!--          templates is to provide a convenient way for an XSLT -->
     <!--          application to retrieve information about an OWL     -->
     <!--          Ontology.                                            -->
     <!--                                                               -->
     <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->

     <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->
     <!--                                                               -->
     <!--  getProperties(classURI) returns a list of space-separated    -->
     <!--                          property URIs.                       -->
     <!--                                                               -->
     <!-- Example: Calling the template with:                           -->
     <!--                                                               -->
     <!--     http://www.xfront.com/owl/ontologies/camera/#Camera       -->
     <!--                                                               -->
     <!-- results in returning:                                         -->
     <!--                                                               -->
     <!-- http://www.xfront.com/owl/ontologies/camera/#lens             -->
     <!-- http://www.xfront.com/owl/ontologies/camera/#body             -->
     <!-- http://www.xfront.com/owl/ontologies/camera/#viewFinder       -->
     <!-- http://www.xfront.com/owl/ontologies/camera/#cost             -->
     <!--                                                               -->
     <!-- Note: I showed the results separated by "carriage return".    -->
     <!-- However, they are actually separated by a space.              -->
     <!--                                                               -->
     <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->

    <xsl:template name="getProperties">
        <xsl:param name="classURI"/>

        <xsl:variable name="superClasses">
            <xsl:call-template name="getSuperClasses">
                <xsl:with-param name="classURI" select="$classURI"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="superClassesPlusSelf" select="concat($superClasses, ' ', $classURI)"/>

        <xsl:call-template name="getProperties-recurseThroughList">
            <xsl:with-param name="classList" select="$superClassesPlusSelf"/>
        </xsl:call-template>

    </xsl:template>

     <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->
     <!--                                                               -->
     <!--  getEquivalentProperties(propertyURI) returns a list of       -->
     <!--                          space-separated property URIs.       -->
     <!--                                                               -->
     <!-- Example: Calling the template with:                           -->
     <!--                                                               -->
     <!--     http://www.xfront.com/owl/ontologies/camera/#size         -->
     <!--                                                               -->
     <!-- results in returning:                                         -->
     <!--                                                               -->
     <!-- http://www.xfront.com/owl/ontologies/camera/#focal-length     -->
     <!--                                                               -->
     <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->

    <xsl:template name="getEquivalentProperties">
        <xsl:param name="propertyURI"/>

        <xsl:call-template name="getEquivalentProperties-recursive">
            <xsl:with-param name="propertyURI" select="$propertyURI"/>
        </xsl:call-template>

    </xsl:template>

     <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->
     <!--                                                               -->
     <!--  getSuperClasses(classURI) returns a list of space-separated  -->
     <!--                          class URIs.                          -->
     <!--                                                               -->
     <!-- Example: Calling the template with:                           -->
     <!--                                                               -->
     <!--     http://www.xfront.com/owl/ontologies/camera/#SLR          -->
     <!--                                                               -->
     <!-- results in returning:                                         -->
     <!--                                                               -->
     <!-- http://www.xfront.com/owl/ontologies/camera/#Camera           -->
     <!-- http://www.xfront.com/owl/ontologies/camera/#PurchaseableItem -->
     <!--                                                               -->
     <!-- Note: I showed the results separated by "carriage return".    -->
     <!-- However, they are actually separated by a space.              -->
     <!--                                                               -->
     <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->

    <xsl:template name="getSuperClasses">
        <xsl:param name="classURI"/>

	<!-- <xsl:text>calling getSuperClasses with parameter: </xsl:text>
	<xsl:value-of select="$classURI"/> -->

	<!-- get the name of the class from the class URI -->
        <xsl:variable name="className">
            <xsl:call-template name="getLocalName">
                <xsl:with-param name="URI" select="$classURI"/>
            </xsl:call-template>
        </xsl:variable>
	<!-- get the namespace of the class from the class URI -->
        <xsl:variable name="namespace">
            <xsl:call-template name="getNamespace">
                <xsl:with-param name="URI" select="$classURI"/>
            </xsl:call-template>
        </xsl:variable>
	<!-- get the file name of the ontology from the namespace 
	     (look it up in OntologyDirectory.xsl) -->
        <xsl:variable name="ontologyDocument">
            <xsl:call-template name="getNameOfOntologyDocument">
                <xsl:with-param name="namespace" select="$namespace"/>
            </xsl:call-template>
        </xsl:variable>
	

	<xsl:value-of select="$className"/>
	<xsl:value-of select="$namespace"/>
	<xsl:value-of select="$ontologyDocument"/>


	<!-- get the entire ontology loaded in the variable $ontology-->
        <xsl:variable name="ontology" select="document($ontologyDocument)"/>
        
	<xsl:choose>
	    <!-- if we've reached owl#Thing, do nothing: no more superclasses
                 to be found -->
            <xsl:when test="$className='http://www.w3.org/2002/07/owl#Thing'"/>
            <xsl:when test="$ontology/rdf:RDF/*[@rdf:about=$className]">
                <xsl:variable name="classNode" select="$ontology//*[@rdf:about=$className]"/>
                <xsl:call-template name="getSuperClassesOfNode">
                    <xsl:with-param name="classNode" select="$classNode"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>

            </xsl:when>
            <xsl:when test="$ontology/rdf:RDF/*[@rdf:about=$classURI]">
                <xsl:variable name="classNode" select="$ontology//*[@rdf:about=$classURI]"/>
                <xsl:call-template name="getSuperClassesOfNode">
                    <xsl:with-param name="classNode" select="$classNode"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>

            </xsl:when>
            <xsl:when test="$ontology/rdf:RDF/*[@rdf:about=concat('#',$className)]">
                <xsl:variable name="classNode" select="$ontology//*[@rdf:about=concat('#',$className)]"/>
                <xsl:call-template name="getSuperClassesOfNode">
                    <xsl:with-param name="classNode" select="$classNode"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>

            </xsl:when>
            <xsl:when test="$ontology/rdf:RDF/*[@rdf:ID=$className]">
                <xsl:variable name="classNode" select="$ontology//*[@rdf:ID=$className]"/>
                <xsl:call-template name="getSuperClassesOfNode">
                    <xsl:with-param name="classNode" select="$classNode"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>

            </xsl:when>
            <xsl:when test="$ontology/rdf:RDF/*[@rdf:ID=concat('#',$className)]">
                <xsl:variable name="classNode" select="$ontology//*[@rdf:ID=concat('#',$className)]"/>
                <xsl:call-template name="getSuperClassesOfNode">
                    <xsl:with-param name="classNode" select="$classNode"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>
		<xsl:value-of select="$classNode"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

     <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->
     <!--                                                               -->
     <!--  getPropertyTypes(propertyURI) returns a list of              -->
     <!--                          space-separated type URIs.           -->
     <!--                                                               -->
     <!-- Example: Calling the template with:                           -->
     <!--                                                               -->
     <!--     http://www.xfront.com/owl/ontologies/gunLicense/#serial   -->
     <!--                                                               -->
     <!-- results in returning:                                         -->
     <!--                                                               -->
     <!-- http://www.w3.org/2002/07/owl#DatatypeProperty                -->
     <!-- http://www.w3.org/2002/07/owl#FunctionalProperty              -->
     <!-- http://www.w3.org/2002/07/owl#InverseFunctionalProperty       -->
     <!--                                                               -->
     <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->

    <xsl:template name="getPropertyTypes">
        <xsl:param name="propertyURI"/>

        <xsl:variable name="propertyName">
            <xsl:call-template name="getLocalName">
                <xsl:with-param name="URI" select="$propertyURI"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="namespace">
            <xsl:call-template name="getNamespace">
                <xsl:with-param name="URI" select="$propertyURI"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="ontologyDocument">
            <xsl:call-template name="getNameOfOntologyDocument">
                <xsl:with-param name="namespace" select="$namespace"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="ontology" select="document($ontologyDocument)"/>
        <xsl:choose>
            <xsl:when test="$propertyName='http://www.w3.org/2002/07/owl#Thing'"/>
            <xsl:when test="$ontology/rdf:RDF/*[@rdf:about=$propertyName]">
                <xsl:variable name="propertyNode" select="$ontology//*[@rdf:about=$propertyName]"/>
                <xsl:call-template name="getPropertyTypesOfNode">
                    <xsl:with-param name="propertyNode" select="$propertyNode"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$ontology/rdf:RDF/*[@rdf:about=$propertyURI]">
                <xsl:variable name="propertyNode" select="$ontology//*[@rdf:about=$propertyURI]"/>
                <xsl:call-template name="getPropertyTypesOfNode">
                    <xsl:with-param name="propertyNode" select="$propertyNode"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$ontology/rdf:RDF/*[@rdf:about=concat('#',$propertyName)]">
                <xsl:variable name="propertyNode" select="$ontology//*[@rdf:about=concat('#',$propertyName)]"/>
                <xsl:call-template name="getPropertyTypesOfNode">
                    <xsl:with-param name="propertyNode" select="$propertyNode"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$ontology/rdf:RDF/*[@rdf:ID=$propertyName]">
                <xsl:variable name="propertyNode" select="$ontology//*[@rdf:ID=$propertyName]"/>
                <xsl:call-template name="getPropertyTypesOfNode">
                    <xsl:with-param name="propertyNode" select="$propertyNode"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$ontology/rdf:RDF/*[@rdf:ID=concat('#',$propertyName)]">
                <xsl:variable name="propertyNode" select="$ontology//*[@rdf:ID=concat('#',$propertyName)]"/>
                <xsl:call-template name="getPropertyTypesOfNode">
                    <xsl:with-param name="propertyNode" select="$propertyNode"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>

    </xsl:template>

     <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->
     <!--                                                               -->
     <!--  getClassSpecificPropertyDefinitions(classURI, propertyURI)   -->
     <!--  returns a list of space-separated property=value URI pairs.  -->
     <!--                                                               -->
     <!-- Example: Calling the template with:                           -->
     <!--                                                               -->
     <!--     http://www.xfront.com/owl/ontologies/water/#River         -->
     <!--     http://www.xfront.com/owl/ontologies/water/#connectsTo    -->
     <!--                                                               -->
     <!-- results in returning:                                         -->
     <!--                                                               -->
     <!-- http://www.w3.org/2002/07/owl#someValuesFrom=http://www.xfront.com/owl/ontologies/water/#BodyOfWater -->
     <!--                                                               -->
     <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->

    <xsl:template name="getClassSpecificPropertyDefinitions">
        <xsl:param name="classURI"/>
        <xsl:param name="propertyURI"/>

        <xsl:variable name="className">
            <xsl:call-template name="getLocalName">
                <xsl:with-param name="URI" select="$classURI"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="namespace">
            <xsl:call-template name="getNamespace">
                <xsl:with-param name="URI" select="$classURI"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="ontologyDocument">
            <xsl:call-template name="getNameOfOntologyDocument">
                <xsl:with-param name="namespace" select="$namespace"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="ontology" select="document($ontologyDocument)"/>
        <xsl:choose>
            <xsl:when test="$className='http://www.w3.org/2002/07/owl#Thing'"/>
            <xsl:when test="$ontology/rdf:RDF/*[@rdf:about=$className]">
                <xsl:variable name="classNode" select="$ontology//*[@rdf:about=$className]"/>
                <xsl:call-template name="getClassSpecificPropertyDefinitionsOfNode">
                    <xsl:with-param name="classNode" select="$classNode"/>
                    <xsl:with-param name="propertyURI" select="$propertyURI"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$ontology/rdf:RDF/*[@rdf:about=$classURI]">
                <xsl:variable name="classNode" select="$ontology//*[@rdf:about=$classURI]"/>
                <xsl:call-template name="getClassSpecificPropertyDefinitionsOfNode">
                    <xsl:with-param name="classNode" select="$classNode"/>
                    <xsl:with-param name="propertyURI" select="$propertyURI"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$ontology/rdf:RDF/*[@rdf:about=concat('#',$className)]">
                <xsl:variable name="classNode" select="$ontology//*[@rdf:about=concat('#',$className)]"/>
                <xsl:call-template name="getClassSpecificPropertyDefinitionsOfNode">
                    <xsl:with-param name="classNode" select="$classNode"/>
                    <xsl:with-param name="propertyURI" select="$propertyURI"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$ontology/rdf:RDF/*[@rdf:ID=$className]">
                <xsl:variable name="classNode" select="$ontology//*[@rdf:ID=$className]"/>
                <xsl:call-template name="getClassSpecificPropertyDefinitionsOfNode">
                    <xsl:with-param name="classNode" select="$classNode"/>
                    <xsl:with-param name="propertyURI" select="$propertyURI"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$ontology/rdf:RDF/*[@rdf:ID=concat('#',$className)]">
                <xsl:variable name="classNode" select="$ontology//*[@rdf:ID=concat('#',$className)]"/>
                <xsl:call-template name="getClassSpecificPropertyDefinitionsOfNode">
                    <xsl:with-param name="classNode" select="$classNode"/>
                    <xsl:with-param name="propertyURI" select="$propertyURI"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

     <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->
     <!--                                                               -->
     <!--  getDomain(propertyURI) returns a list of                     -->
     <!--                         space-separated class URIs.           -->
     <!--                                                               -->
     <!-- Example: Calling the template with:                           -->
     <!--                                                               -->
     <!--     http://www.xfront.com/owl/ontologies/water/#emptiesInto   -->
     <!--                                                               -->
     <!-- results in returning:                                         -->
     <!--                                                               -->
     <!-- http://www.xfront.com/owl/ontologies/water/#River             -->
     <!--                                                               -->
     <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->

    <xsl:template name="getDomain">
        <xsl:param name="propertyURI"/>

        <xsl:variable name="propertyName">
            <xsl:call-template name="getLocalName">
                <xsl:with-param name="URI" select="$propertyURI"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="namespace">
            <xsl:call-template name="getNamespace">
                <xsl:with-param name="URI" select="$propertyURI"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="ontologyDocument">
            <xsl:call-template name="getNameOfOntologyDocument">
                <xsl:with-param name="namespace" select="$namespace"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="ontology" select="document($ontologyDocument)"/>
        <xsl:choose>
            <xsl:when test="$propertyName='http://www.w3.org/2002/07/owl#Thing'"/>
            <xsl:when test="$ontology/rdf:RDF/*[@rdf:about=$propertyName]">
                <xsl:variable name="propertyNode" select="$ontology//*[@rdf:about=$propertyName]"/>
                <xsl:call-template name="getDomainOfNode">
                    <xsl:with-param name="propertyNode" select="$propertyNode"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$ontology/rdf:RDF/*[@rdf:about=$propertyURI]">
                <xsl:variable name="propertyNode" select="$ontology//*[@rdf:about=$propertyURI]"/>
                <xsl:call-template name="getDomainOfNode">
                    <xsl:with-param name="propertyNode" select="$propertyNode"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$ontology/rdf:RDF/*[@rdf:about=concat('#',$propertyName)]">
                <xsl:variable name="propertyNode" select="$ontology//*[@rdf:about=concat('#',$propertyName)]"/>
                <xsl:call-template name="getDomainOfNode">
                    <xsl:with-param name="propertyNode" select="$propertyNode"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$ontology/rdf:RDF/*[@rdf:ID=$propertyName]">
                <xsl:variable name="propertyNode" select="$ontology//*[@rdf:ID=$propertyName]"/>
                <xsl:call-template name="getDomainOfNode">
                    <xsl:with-param name="propertyNode" select="$propertyNode"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$ontology/rdf:RDF/*[@rdf:ID=concat('#',$propertyName)]">
                <xsl:variable name="propertyNode" select="$ontology//*[@rdf:ID=concat('#',$propertyName)]"/>
                <xsl:call-template name="getDomainOfNode">
                    <xsl:with-param name="propertyNode" select="$propertyNode"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>

    </xsl:template>

     <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->
     <!--                                                               -->
     <!--  getRange(propertyURI) returns a list of                      -->
     <!--                         space-separated class URIs.           -->
     <!--                                                               -->
     <!-- Example: Calling the template with:                           -->
     <!--                                                               -->
     <!--     http://www.xfront.com/owl/ontologies/water/#emptiesInto   -->
     <!--                                                               -->
     <!-- results in returning:                                         -->
     <!--                                                               -->
     <!-- http://www.xfront.com/owl/ontologies/water/#BodyOfWater       -->
     <!--                                                               -->
     <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->

    <xsl:template name="getRange">
        <xsl:param name="propertyURI"/>

        <xsl:variable name="propertyName">
            <xsl:call-template name="getLocalName">
                <xsl:with-param name="URI" select="$propertyURI"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="namespace">
            <xsl:call-template name="getNamespace">
                <xsl:with-param name="URI" select="$propertyURI"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="ontologyDocument">
            <xsl:call-template name="getNameOfOntologyDocument">
                <xsl:with-param name="namespace" select="$namespace"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="ontology" select="document($ontologyDocument)"/>
        <xsl:choose>
            <xsl:when test="$propertyName='http://www.w3.org/2002/07/owl#Thing'"/>
            <xsl:when test="$ontology/rdf:RDF/*[@rdf:about=$propertyName]">
                <xsl:variable name="propertyNode" select="$ontology//*[@rdf:about=$propertyName]"/>
                <xsl:call-template name="getRangeOfNode">
                    <xsl:with-param name="propertyNode" select="$propertyNode"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$ontology/rdf:RDF/*[@rdf:about=$propertyURI]">
                <xsl:variable name="propertyNode" select="$ontology//*[@rdf:about=$propertyURI]"/>
                <xsl:call-template name="getRangeOfNode">
                    <xsl:with-param name="propertyNode" select="$propertyNode"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$ontology/rdf:RDF/*[@rdf:about=concat('#',$propertyName)]">
                <xsl:variable name="propertyNode" select="$ontology//*[@rdf:about=concat('#',$propertyName)]"/>
                <xsl:call-template name="getRangeOfNode">
                    <xsl:with-param name="propertyNode" select="$propertyNode"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$ontology/rdf:RDF/*[@rdf:ID=$propertyName]">
                <xsl:variable name="propertyNode" select="$ontology//*[@rdf:ID=$propertyName]"/>
                <xsl:call-template name="getRangeOfNode">
                    <xsl:with-param name="propertyNode" select="$propertyNode"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$ontology/rdf:RDF/*[@rdf:ID=concat('#',$propertyName)]">
                <xsl:variable name="propertyNode" select="$ontology//*[@rdf:ID=concat('#',$propertyName)]"/>
                <xsl:call-template name="getRangeOfNode">
                    <xsl:with-param name="propertyNode" select="$propertyNode"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>

    </xsl:template>

     <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->
     <!--                                                               -->
     <!--  getInstances(classURI) returns a list of                     -->
     <!--                         space-separated instance URIs.        -->
     <!--                                                               -->
     <!-- Example: Calling the template with:                           -->
     <!--                                                               -->
     <!-- http://www.xfront.com/owl/ontologies/water/#Kyoto-Protected-River -->
     <!--                                                               -->
     <!-- results in returning:                                         -->
     <!--                                                               -->
     <!-- http://www.china.org/geography/rivers#Yangtze                 -->
     <!-- http://www.us.org/rivers#Mississippi                          -->
     <!-- http://www.africa.org/rivers#Nile                             -->
     <!-- http://www.s-america.org/rivers#Amazon                        -->
     <!--                                                               -->
     <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->

    <xsl:template name="getInstances">
        <xsl:param name="classURI"/>

        <xsl:variable name="className">
            <xsl:call-template name="getLocalName">
                <xsl:with-param name="URI" select="$classURI"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="namespace">
            <xsl:call-template name="getNamespace">
                <xsl:with-param name="URI" select="$classURI"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="ontologyDocument">
            <xsl:call-template name="getNameOfOntologyDocument">
                <xsl:with-param name="namespace" select="$namespace"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="ontology" select="document($ontologyDocument)"/>
        <xsl:choose>
            <xsl:when test="$className='http://www.w3.org/2002/07/owl#Thing'"/>
            <xsl:when test="$ontology/rdf:RDF/*[@rdf:about=$className]">
                <xsl:variable name="classNode" select="$ontology//*[@rdf:about=$className]"/>
                <xsl:call-template name="getInstancesOfNode">
                    <xsl:with-param name="classNode" select="$classNode"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$ontology/rdf:RDF/*[@rdf:about=$classURI]">
                <xsl:variable name="classNode" select="$ontology//*[@rdf:about=$classURI]"/>
                <xsl:call-template name="getInstancesOfNode">
                    <xsl:with-param name="classNode" select="$classNode"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$ontology/rdf:RDF/*[@rdf:about=concat('#',$className)]">
                <xsl:variable name="classNode" select="$ontology//*[@rdf:about=concat('#',$className)]"/>
                <xsl:call-template name="getInstancesOfNode">
                    <xsl:with-param name="classNode" select="$classNode"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$ontology/rdf:RDF/*[@rdf:ID=$className]">
                <xsl:variable name="classNode" select="$ontology//*[@rdf:ID=$className]"/>
                <xsl:call-template name="getInstancesOfNode">
                    <xsl:with-param name="classNode" select="$classNode"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$ontology/rdf:RDF/*[@rdf:ID=concat('#',$className)]">
                <xsl:variable name="classNode" select="$ontology//*[@rdf:ID=concat('#',$className)]"/>
                <xsl:call-template name="getInstancesOfNode">
                    <xsl:with-param name="classNode" select="$classNode"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>

    </xsl:template>

     <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->
     <!--                                                               -->
     <!--  getEquivalentClasses(classURI) returns a list of             -->
     <!--                         space-separated class URIs.           -->
     <!--                                                               -->
     <!-- Example: Calling the template with:                           -->
     <!--                                                               -->
     <!-- http://www.xfront.com/owl/ontologies/water/#BodyOfWater       -->
     <!--                                                               -->
     <!-- results in returning:                                         -->
     <!--                                                               -->
     <!-- http://www.other.org#WaterGeoFeature                          -->
     <!--                                                               -->
     <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->

    <xsl:template name="getEquivalentClasses">
        <xsl:param name="classURI"/>

        <xsl:call-template name="getEquivalentClasses-recursive">
            <xsl:with-param name="classURI" select="$classURI"/>
        </xsl:call-template>

    </xsl:template>


</xsl:stylesheet>