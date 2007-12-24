This is a now abandoned code base of XSL stylesheets that understands OWL 1.0, more or less.

In the original demo, camera.xsl processed some camera.xml and retrieved information that was being sought.

In my messing around with camera.xsl, I have replaced some but not all of the code in here with some that was
intended to work with an early version of the SAO.

OntologyDirectory.xsl needs to include namespace/filename mappings for the files you are interested in using.

I did find that there were certain ways that Protege writes OWL files that had to be added into the OWL-Genie.xsl
and Private.xsl (which OWL-Genie.xsl references).  I don't think these stylesheets are ready for primetime, 
but they are a whole lot better than starting from scratch, if you are interested in processing OWL with XSL
at an advanced level.  

If nothing else, these functions may be useful as parts of other projects.