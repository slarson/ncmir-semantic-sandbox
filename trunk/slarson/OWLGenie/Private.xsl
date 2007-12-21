<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:owl="http://www.w3.org/2002/07/owl#"
                version="1.0">
 
     <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->
     <!--                                                                -->
     <!--                     OWL Genie - Private Templates              -->
     <!--                                                                -->
     <!-- Author: Roger L. Costello                                      -->
     <!--                                                                -->
     <!-- Purpose: The purpose of these named templates is to provide    -->
     <!--          support routines for the "public" OWL Genie templates -->
     <!--                                                                -->
     <!-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -->

    <xsl:template name="getEquivalentProperties-recursive">
        <xsl:param name="propertyURI"/>
        <xsl:param name="equivalentPropertiesList" select="$propertyURI"/>

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

        <xsl:for-each select="$ontology/rdf:RDF/*[@rdf:ID=$propertyName]/owl:equivalentProperty[./@rdf:resource]">
            <xsl:variable name="equivalentProperty">
                <xsl:call-template name="getURI">
                    <xsl:with-param name="name" select="@rdf:resource"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="not(contains($equivalentPropertiesList, $equivalentProperty))">
                    <xsl:value-of select="$equivalentProperty"/>
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="getEquivalentProperties-recursive">
                        <xsl:with-param name="propertyURI" select="$equivalentProperty"/>
                        <xsl:with-param name="equivalentPropertiesList" select="concat($equivalentPropertiesList, ' ', $equivalentProperty)"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select="$ontology/rdf:RDF/*[@rdf:ID=concat('#', $propertyName)]/owl:equivalentProperty[./@rdf:resource]">
            <xsl:variable name="equivalentProperty">
                <xsl:call-template name="getURI">
                    <xsl:with-param name="name" select="@rdf:resource"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="not(contains($equivalentPropertiesList, $equivalentProperty))">
                    <xsl:value-of select="$equivalentProperty"/>
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="getEquivalentProperties-recursive">
                        <xsl:with-param name="propertyURI" select="$equivalentProperty"/>
                        <xsl:with-param name="equivalentPropertiesList" select="concat($equivalentPropertiesList, ' ', $equivalentProperty)"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select="$ontology/rdf:RDF/*[@rdf:ID=$propertyURI]/owl:equivalentProperty[./@rdf:resource]">
            <xsl:variable name="equivalentProperty">
                <xsl:call-template name="getURI">
                    <xsl:with-param name="name" select="@rdf:resource"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="not(contains($equivalentPropertiesList, $equivalentProperty))">
                    <xsl:value-of select="$equivalentProperty"/>
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="getEquivalentProperties-recursive">
                        <xsl:with-param name="propertyURI" select="$equivalentProperty"/>
                        <xsl:with-param name="equivalentPropertiesList" select="concat($equivalentPropertiesList, ' ', $equivalentProperty)"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select="$ontology/rdf:RDF/*[@rdf:about=$propertyName]/owl:equivalentProperty[./@rdf:resource]">
            <xsl:variable name="equivalentProperty">
                <xsl:call-template name="getURI">
                    <xsl:with-param name="name" select="@rdf:resource"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="not(contains($equivalentPropertiesList, $equivalentProperty))">
                    <xsl:value-of select="$equivalentProperty"/>
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="getEquivalentProperties-recursive">
                        <xsl:with-param name="propertyURI" select="$equivalentProperty"/>
                        <xsl:with-param name="equivalentPropertiesList" select="concat($equivalentPropertiesList, ' ', $equivalentProperty)"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select="$ontology/rdf:RDF/*[@rdf:about=concat('#', $propertyName)]/owl:equivalentProperty[./@rdf:resource]">
            <xsl:variable name="equivalentProperty">
                <xsl:call-template name="getURI">
                    <xsl:with-param name="name" select="@rdf:resource"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="not(contains($equivalentPropertiesList, $equivalentProperty))">
                    <xsl:value-of select="$equivalentProperty"/>
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="getEquivalentProperties-recursive">
                        <xsl:with-param name="propertyURI" select="$equivalentProperty"/>
                        <xsl:with-param name="equivalentPropertiesList" select="concat($equivalentPropertiesList, ' ', $equivalentProperty)"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select="$ontology/rdf:RDF/*[@rdf:about=$propertyURI]/owl:equivalentProperty[./@rdf:resource]">
            <xsl:variable name="equivalentProperty">
                <xsl:call-template name="getURI">
                    <xsl:with-param name="name" select="@rdf:resource"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="not(contains($equivalentPropertiesList, $equivalentProperty))">
                    <xsl:value-of select="$equivalentProperty"/>
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="getEquivalentProperties-recursive">
                        <xsl:with-param name="propertyURI" select="$equivalentProperty"/>
                        <xsl:with-param name="equivalentPropertiesList" select="concat($equivalentPropertiesList, ' ', $equivalentProperty)"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select="$ontology/rdf:RDF/*[./owl:equivalentProperty/@rdf:resource=$propertyName]">
            <xsl:variable name="equivalentProperty">
                <xsl:choose>
                    <xsl:when test="./@rdf:ID">
                        <xsl:call-template name="getURI">
                            <xsl:with-param name="name" select="./@rdf:ID"/>
                            <xsl:with-param name="ontology" select="$ontology"/>
                       </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="./@rdf:about">
                        <xsl:call-template name="getURI">
                            <xsl:with-param name="name" select="rdf:about"/>
                            <xsl:with-param name="ontology" select="$ontology"/>
                       </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="not(contains($equivalentPropertiesList, $equivalentProperty))">
                    <xsl:value-of select="$equivalentProperty"/>
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="getEquivalentProperties-recursive">
                        <xsl:with-param name="propertyURI" select="$equivalentProperty"/>
                        <xsl:with-param name="equivalentPropertiesList" select="concat($equivalentPropertiesList, ' ', $equivalentProperty)"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select="$ontology/rdf:RDF/*[./owl:equivalentProperty/@rdf:resource=concat('#', $propertyName)]">
            <xsl:variable name="equivalentProperty">
                <xsl:choose>
                    <xsl:when test="./@rdf:ID">
                        <xsl:call-template name="getURI">
                            <xsl:with-param name="name" select="./@rdf:ID"/>
                            <xsl:with-param name="ontology" select="$ontology"/>
                       </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="./@rdf:about">
                        <xsl:call-template name="getURI">
                            <xsl:with-param name="name" select="rdf:about"/>
                            <xsl:with-param name="ontology" select="$ontology"/>
                       </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="not(contains($equivalentPropertiesList, $equivalentProperty))">
                    <xsl:value-of select="$equivalentProperty"/>
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="getEquivalentProperties-recursive">
                        <xsl:with-param name="propertyURI" select="$equivalentProperty"/>
                        <xsl:with-param name="equivalentPropertiesList" select="concat($equivalentPropertiesList, ' ', $equivalentProperty)"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select="$ontology/rdf:RDF/*[./owl:equivalentProperty/@rdf:resource=$propertyURI]">
            <xsl:variable name="equivalentProperty">
                <xsl:choose>
                    <xsl:when test="./@rdf:ID">
                        <xsl:call-template name="getURI">
                            <xsl:with-param name="name" select="./@rdf:ID"/>
                            <xsl:with-param name="ontology" select="$ontology"/>
                       </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="./@rdf:about">
                        <xsl:call-template name="getURI">
                            <xsl:with-param name="name" select="rdf:about"/>
                            <xsl:with-param name="ontology" select="$ontology"/>
                       </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="not(contains($equivalentPropertiesList, $equivalentProperty))">
                    <xsl:value-of select="$equivalentProperty"/>
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="getEquivalentProperties-recursive">
                        <xsl:with-param name="propertyURI" select="$equivalentProperty"/>
                        <xsl:with-param name="equivalentPropertiesList" select="concat($equivalentPropertiesList, ' ', $equivalentProperty)"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>

    </xsl:template>


    <xsl:template name="getProperties-recurseThroughList">
        <xsl:param name="classList"/>

        <xsl:variable name="normalizedClassList" select="normalize-space(translate($classList, '{}', '  '))"/>
        <xsl:choose>
            <xsl:when test="$normalizedClassList">
                <xsl:choose>
                    <xsl:when test="substring-before($normalizedClassList, ' ')">
                        <xsl:variable name="classURI" select="substring-before($normalizedClassList, ' ')"/>
                        <xsl:call-template name="getProperties-IgnoreInheritedProperties">
                            <xsl:with-param name="classURI" select="$classURI"/>
                        </xsl:call-template>
                        <xsl:call-template name="getProperties-recurseThroughList">
                            <xsl:with-param name="classList" select="substring-after($normalizedClassList, ' ')"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="classURI" select="$normalizedClassList"/>
                        <xsl:call-template name="getProperties-IgnoreInheritedProperties">
                            <xsl:with-param name="classURI" select="$classURI"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>

    </xsl:template>

    <xsl:template name="getProperties-IgnoreInheritedProperties">
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

        <xsl:for-each select="$ontology/rdf:RDF/*[(./rdfs:domain/@rdf:resource=$className) or (./rdfs:domain/@rdf:resource=concat('#', $className)) or (./rdfs:domain/@rdf:resource=$classURI)]">
            <xsl:variable name="propertyURI">
                <xsl:choose>
                    <xsl:when test="./@rdf:about">
                        <xsl:call-template name="getURI">
                            <xsl:with-param name="name" select="@rdf:about"/>
                            <xsl:with-param name="ontology" select="$ontology"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="./@rdf:ID">
                        <xsl:call-template name="getURI">
                            <xsl:with-param name="name" select="@rdf:ID"/>
                            <xsl:with-param name="ontology" select="$ontology"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            <xsl:value-of select="$propertyURI"/>
            <xsl:text> </xsl:text>
        </xsl:for-each>

    </xsl:template>

    <!-- Look up the superclasses of the node passed into $classNode
         in the ontology passed in through $ontology.  Return the answer
         through xsl:text directly onto the output -->
    <xsl:template name="getSuperClassesOfNode">
        <xsl:param name="classNode"/>
        <xsl:param name="ontology"/>

	<!--
	<xsl:text>Calling getSuperClassesOfNode</xsl:text>
	-->

	<!-- count the number of classes this class is subClassOf
             under $classNode into 
             $subClassCount variable by appending "1"s together 
             using two criteria for what qualifies as a subclass-->
        <xsl:variable name="subClassCount">
	    <!-- criteria #1: count number of subClassOf tags with 
                              rdf:resource attributes -->
            <xsl:for-each select="$classNode/rdfs:subClassOf/@rdf:resource">
                <xsl:text>1</xsl:text>
            </xsl:for-each>
	    <!-- criteria #2: count number of Class tags under rdfs:subClassOf 
                              tags with rdf:about attributes -->
            <xsl:for-each select="$classNode/rdfs:subClassOf/*[local-name(.)='Class']/@rdf:about">
                <xsl:text>1</xsl:text>
            </xsl:for-each>
        </xsl:variable>

        <!-- handle a single subclass differently than multiple subclasses -->
        <xsl:choose>
            <xsl:when test="string-length($subClassCount) &gt; 1">
		<!-- Subclass count greater than 1 -->
                <xsl:for-each select="$classNode/rdfs:subClassOf[./@rdf:resource]">
                    <xsl:text>{</xsl:text>
                        <xsl:variable name="parentClassURI">
                            <xsl:call-template name="getURI">
                                <xsl:with-param name="name" select="./@rdf:resource"/>
                                <xsl:with-param name="ontology" select="$ontology"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:call-template name="getSuperClasses">
                            <xsl:with-param name="classURI" select="$parentClassURI"/>
                        </xsl:call-template>
                        <xsl:choose>
                            <xsl:when test="$parentClassURI!='http://www.w3.org/2002/07/owl#Thing'">
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="$parentClassURI"/>
                            </xsl:when>
                        </xsl:choose>
                    <xsl:text>}</xsl:text>
                </xsl:for-each>
                
		<!-- unused block .. this xpath test picks too many nodes -->
		<!-- this xpath test differs from the one that would be used
                     up above in the presence of [./@rdf:about] instead of
                     /@rdf:about
                -->
		<!--
		<xsl:for-each select="$classNode//*[local-name(.)='Class'][./@rdf:about]">
                    <xsl:text>{</xsl:text>
                        <xsl:variable name="parentClassURI">
                            <xsl:call-template name="getURI">
                                <xsl:with-param name="name" select="./@rdf:about"/>
                                <xsl:with-param name="ontology" select="$ontology"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:call-template name="getSuperClasses">
                            <xsl:with-param name="classURI" select="$parentClassURI"/>
                        </xsl:call-template>
                        <xsl:choose>
                            <xsl:when test="$parentClassURI!='http://www.w3.org/2002/07/owl#Thing'">
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="$parentClassURI"/>
                            </xsl:when>
                        </xsl:choose>
                    <xsl:text>}</xsl:text>
                </xsl:for-each>
                -->
            </xsl:when>
            <xsl:when test="string-length($subClassCount) = 1">
		<!-- Subclass count equals 1 -->
                <xsl:for-each select="$classNode/rdfs:subClassOf[./@rdf:resource]">
		    <!-- using criteria #1 (see above) -->
                    <xsl:variable name="parentClassURI">
                        <xsl:call-template name="getURI">
                            <xsl:with-param name="name" select="./@rdf:resource"/>
                            <xsl:with-param name="ontology" select="$ontology"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:call-template name="getSuperClasses">
                        <xsl:with-param name="classURI" select="$parentClassURI"/>
                    </xsl:call-template>
                    <xsl:choose>
                        <xsl:when test="$parentClassURI!='http://www.w3.org/2002/07/owl#Thing'">
                            <xsl:text> </xsl:text>
                            <xsl:value-of select="$parentClassURI"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
            <xsl:for-each select="$classNode/rdfs:subClassOf/*[local-name(.)='Class'][@rdf:about]">
                    <!-- using criteria #2 (see above) -->
                    <xsl:variable name="parentClassURI">
			<!-- get the URI for this Class, which must be a
			     parentClass to $classNode -->
                        <xsl:call-template name="getURI">
                            <xsl:with-param name="name" select="./@rdf:about"/>
                            <xsl:with-param name="ontology" select="$ontology"/>
                        </xsl:call-template>
                    </xsl:variable>
			<!-- call getSuperClasses on this superClass to
			     recursively get full hierarchy
			-->
                    <xsl:call-template name="getSuperClasses">
                        <xsl:with-param name="classURI" select="$parentClassURI"/>
                    </xsl:call-template>
		        <!-- print all $parentClassURI's that aren't
                             equal to the root, owl#Thing
			-->
                    <xsl:choose>
                        <xsl:when test="$parentClassURI!='http://www.w3.org/2002/07/owl#Thing'">
                            <xsl:text> </xsl:text>
                            <xsl:value-of select="$parentClassURI"/>
                        </xsl:when>
                    </xsl:choose>
            </xsl:for-each>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="getPropertyTypesOfNode">
        <xsl:param name="propertyNode"/>

        <xsl:choose>
            <xsl:when test="local-name($propertyNode) != 'Description'">
                <xsl:value-of select="concat(namespace-uri($propertyNode), local-name($propertyNode))"/>
                <xsl:text> </xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:for-each select="$propertyNode/rdf:type">
            <xsl:value-of select="@rdf:resource"/>
            <xsl:text> </xsl:text>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="getClassSpecificPropertyDefinitionsOfNode">
        <xsl:param name="classNode"/>
        <xsl:param name="propertyURI"/>
        <xsl:param name="ontology"/>

        <xsl:choose>
            <xsl:when test="$classNode//owl:Restriction[contains($propertyURI, ./owl:onProperty/@rdf:resource)]">
                <xsl:for-each select="$classNode//owl:Restriction[contains($propertyURI, ./owl:onProperty/@rdf:resource)]">
                    <xsl:variable name="RestrictionNode" select="."/>
                    <xsl:for-each select="$RestrictionNode/*[local-name(.) != 'onProperty']">
                        <xsl:value-of select="concat(namespace-uri(.), local-name(.))"/>
                        <xsl:text>=</xsl:text>
                        <xsl:variable name="uri">
                            <xsl:call-template name="getURI">
                                <xsl:with-param name="name" select="@rdf:resource"/>
                                <xsl:with-param name="ontology" select="$ontology"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:value-of select="$uri"/>
                    </xsl:for-each>
                    <xsl:text> </xsl:text>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>

    </xsl:template>

    <xsl:template name="getDomainOfNode">
        <xsl:param name="propertyNode"/>
        <xsl:param name="ontology"/>

        <xsl:choose>
            <xsl:when test="$propertyNode/rdfs:domain">
                <xsl:for-each select="$propertyNode/rdfs:domain">
                    <xsl:variable name="uri">
                        <xsl:call-template name="getURI">
                            <xsl:with-param name="name" select="@rdf:resource"/>
                            <xsl:with-param name="ontology" select="$ontology"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:value-of select="$uri"/>
                    <xsl:text> </xsl:text>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>

    </xsl:template>

    <xsl:template name="getRangeOfNode">
        <xsl:param name="propertyNode"/>
        <xsl:param name="ontology"/>

        <xsl:choose>
            <xsl:when test="$propertyNode/rdfs:range">
                <xsl:for-each select="$propertyNode/rdfs:range">
                    <xsl:variable name="uri">
                        <xsl:call-template name="getURI">
                            <xsl:with-param name="name" select="@rdf:resource"/>
                            <xsl:with-param name="ontology" select="$ontology"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:value-of select="$uri"/>
                    <xsl:text> </xsl:text>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>

    </xsl:template>

    <xsl:template name="getInstancesOfNode">
        <xsl:param name="classNode"/>
        <xsl:param name="ontology"/>

        <xsl:for-each select="$classNode//owl:oneOf/*">
            <xsl:call-template name="getURI">
                <xsl:with-param name="name" select="@rdf:about"/>
                <xsl:with-param name="ontology" select="$ontology"/>
            </xsl:call-template>
            <xsl:text> </xsl:text>
        </xsl:for-each>

    </xsl:template>

    <xsl:template name="getEquivalentClasses-recursive">
        <xsl:param name="classURI"/>
        <xsl:param name="equivalentClassesList" select="$classURI"/>

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

        <xsl:for-each select="$ontology/rdf:RDF/*[@rdf:ID=$className]/owl:equivalentClass[./@rdf:resource]">
            <xsl:variable name="equivalentClass">
                <xsl:call-template name="getURI">
                    <xsl:with-param name="name" select="@rdf:resource"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="not(contains($equivalentClassesList, $equivalentClass))">
                    <xsl:value-of select="$equivalentClass"/>
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="getEquivalentClasses-recursive">
                        <xsl:with-param name="classURI" select="$equivalentClass"/>
                        <xsl:with-param name="equivalentClassesList" select="concat($equivalentClassesList, ' ', $equivalentClass)"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select="$ontology/rdf:RDF/*[@rdf:ID=concat('#', $className)]/owl:equivalentClass[./@rdf:resource]">
            <xsl:variable name="equivalentClass">
                <xsl:call-template name="getURI">
                    <xsl:with-param name="name" select="@rdf:resource"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="not(contains($equivalentClassesList, $equivalentClass))">
                    <xsl:value-of select="$equivalentClass"/>
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="getEquivalentClasses-recursive">
                        <xsl:with-param name="classURI" select="$equivalentClass"/>
                        <xsl:with-param name="equivalentClassesList" select="concat($equivalentClassesList, ' ', $equivalentClass)"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select="$ontology/rdf:RDF/*[@rdf:ID=$classURI]/owl:equivalentClass[./@rdf:resource]">
            <xsl:variable name="equivalentClass">
                <xsl:call-template name="getURI">
                    <xsl:with-param name="name" select="@rdf:resource"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="not(contains($equivalentClassesList, $equivalentClass))">
                    <xsl:value-of select="$equivalentClass"/>
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="getEquivalentClasses-recursive">
                        <xsl:with-param name="classURI" select="$equivalentClass"/>
                        <xsl:with-param name="equivalentClassesList" select="concat($equivalentClassesList, ' ', $equivalentClass)"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select="$ontology/rdf:RDF/*[@rdf:about=$className]/owl:equivalentClass[./@rdf:resource]">
            <xsl:variable name="equivalentClass">
                <xsl:call-template name="getURI">
                    <xsl:with-param name="name" select="@rdf:resource"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="not(contains($equivalentClassesList, $equivalentClass))">
                    <xsl:value-of select="$equivalentClass"/>
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="getEquivalentClasses-recursive">
                        <xsl:with-param name="classURI" select="$equivalentClass"/>
                        <xsl:with-param name="equivalentClassesList" select="concat($equivalentClassesList, ' ', $equivalentClass)"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select="$ontology/rdf:RDF/*[@rdf:about=concat('#', $className)]/owl:equivalentClass[./@rdf:resource]">
            <xsl:variable name="equivalentClass">
                <xsl:call-template name="getURI">
                    <xsl:with-param name="name" select="@rdf:resource"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="not(contains($equivalentClassesList, $equivalentClass))">
                    <xsl:value-of select="$equivalentClass"/>
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="getEquivalentClasses-recursive">
                        <xsl:with-param name="classURI" select="$equivalentClass"/>
                        <xsl:with-param name="equivalentClassesList" select="concat($equivalentClassesList, ' ', $equivalentClass)"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select="$ontology/rdf:RDF/*[@rdf:about=$classURI]/owl:equivalentClass[./@rdf:resource]">
            <xsl:variable name="equivalentClass">
                <xsl:call-template name="getURI">
                    <xsl:with-param name="name" select="@rdf:resource"/>
                    <xsl:with-param name="ontology" select="$ontology"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="not(contains($equivalentClassesList, $equivalentClass))">
                    <xsl:value-of select="$equivalentClass"/>
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="getEquivalentClasses-recursive">
                        <xsl:with-param name="classURI" select="$equivalentClass"/>
                        <xsl:with-param name="equivalentClassesList" select="concat($equivalentClassesList, ' ', $equivalentClass)"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select="$ontology/rdf:RDF/*[./owl:equivalentClass/@rdf:resource=$className]">
            <xsl:variable name="equivalentClass">
                <xsl:choose>
                    <xsl:when test="./@rdf:ID">
                        <xsl:call-template name="getURI">
                            <xsl:with-param name="name" select="./@rdf:ID"/>
                            <xsl:with-param name="ontology" select="$ontology"/>
                       </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="./@rdf:about">
                        <xsl:call-template name="getURI">
                            <xsl:with-param name="name" select="rdf:about"/>
                            <xsl:with-param name="ontology" select="$ontology"/>
                       </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="not(contains($equivalentClassesList, $equivalentClass))">
                    <xsl:value-of select="$equivalentClass"/>
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="getEquivalentClasses-recursive">
                        <xsl:with-param name="classURI" select="$equivalentClass"/>
                        <xsl:with-param name="equivalentClassesList" select="concat($equivalentClassesList, ' ', $equivalentClass)"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select="$ontology/rdf:RDF/*[./owl:equivalentClass/@rdf:resource=concat('#', $className)]">
            <xsl:variable name="equivalentClass">
                <xsl:choose>
                    <xsl:when test="./@rdf:ID">
                        <xsl:call-template name="getURI">
                            <xsl:with-param name="name" select="./@rdf:ID"/>
                            <xsl:with-param name="ontology" select="$ontology"/>
                       </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="./@rdf:about">
                        <xsl:call-template name="getURI">
                            <xsl:with-param name="name" select="rdf:about"/>
                            <xsl:with-param name="ontology" select="$ontology"/>
                       </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="not(contains($equivalentClassesList, $equivalentClass))">
                    <xsl:value-of select="$equivalentClass"/>
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="getEquivalentClasses-recursive">
                        <xsl:with-param name="classURI" select="$equivalentClass"/>
                        <xsl:with-param name="equivalentClassesList" select="concat($equivalentClassesList, ' ', $equivalentClass)"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select="$ontology/rdf:RDF/*[./owl:equivalentClass/@rdf:resource=$classURI]">
            <xsl:variable name="equivalentClass">
                <xsl:choose>
                    <xsl:when test="./@rdf:ID">
                        <xsl:call-template name="getURI">
                            <xsl:with-param name="name" select="./@rdf:ID"/>
                            <xsl:with-param name="ontology" select="$ontology"/>
                       </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="./@rdf:about">
                        <xsl:call-template name="getURI">
                            <xsl:with-param name="name" select="rdf:about"/>
                            <xsl:with-param name="ontology" select="$ontology"/>
                       </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="not(contains($equivalentClassesList, $equivalentClass))">
                    <xsl:value-of select="$equivalentClass"/>
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="getEquivalentClasses-recursive">
                        <xsl:with-param name="classURI" select="$equivalentClass"/>
                        <xsl:with-param name="equivalentClassesList" select="concat($equivalentClassesList, ' ', $equivalentClass)"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>

    </xsl:template>

    <!-- Given a name and an ontology, return the URI.
         Apply some cleanup if needed -->
    <xsl:template name="getURI">
        <xsl:param name="name"/>
        <xsl:param name="ontology"/>

        <xsl:choose>
            <xsl:when test="contains($name, 'http://')">
                <xsl:value-of select="normalize-space($name)"/>
            </xsl:when>
            <xsl:otherwise> 
                <xsl:variable name="base" select="normalize-space($ontology//@xml:base)"/>
                <xsl:variable name="className">
                    <xsl:call-template name="getLocalName">
                        <xsl:with-param name="URI" select="$name"/>
                    </xsl:call-template>
                </xsl:variable>
                <!-- important: needs to be /# rather than just # 
                     to conform with standard set 
                     in OntologyDirectory.xsl
                -->
                <xsl:value-of select="normalize-space(concat($base, '/#', $className))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="getLocalName">
        <xsl:param name="URI"/>
        <xsl:choose>
            <xsl:when test="contains($URI, '#')">
                <xsl:value-of select="normalize-space(substring-after($URI, '#'))"/>
            </xsl:when>
            <xsl:otherwise> 
                <xsl:value-of select="normalize-space($URI)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="getNamespace">
        <xsl:param name="URI"/>

        <xsl:choose>
            <xsl:when test="contains($URI, '#')">
                <xsl:value-of select="normalize-space(concat(substring-before($URI, '#'),'#'))"/>
            </xsl:when>
            <xsl:otherwise> 
                <xsl:value-of select="normalize-space($URI)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>