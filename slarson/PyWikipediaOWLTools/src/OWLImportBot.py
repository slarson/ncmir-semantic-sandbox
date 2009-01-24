#from rdflib import Graph, URIRef, Literal, Namespace, RDF
import sys
import subprocess

sys.path.append("../../pywikipedia/")
sys.path.append("../../pywikipedia/userinterfaces")
sys.path.append("../../pywikipedia/families")
sys.path.append("families")

import wikipedia, login, string

from xml.sax import saxutils
from xml.sax import make_parser
from xml.sax.handler import feature_namespaces
from xml.sax.handler import ContentHandler

#Reads a TreeML processed version of the NIFSTD ontology and writes classes
# to openccdb.org/ontowiki.  The TreeML is too large to be loaded into memory, so
# it is processed using a sax parser.
# Tests to see if current page would be changed before updating.
# Performs a diff comparison
#
# author: Stephen D. Larson
# last modified: 01-21-09

class WriteWikipediaFromTreeML(ContentHandler):
    
    def __init__(self):
        self.clearVars()
        self.ow = wikipedia.Site('en', 'nif')
        login.LoginManager('bot', 'NifBot', self.ow)

	print "\nLogged in to Neurolex.org.  Ready to start updating!"

        self.unchanged = list()
	self.iterations = 10
	self.currentIteration = 0
        
    def startElement(self, elName, attrs):
       
        if elName == 'attribute': 
        
            # look for the name and value attributes 
            name = attrs.get('name', None)
            value = attrs.get('value', None)
            
            if name == "label" :
                self.label = value
            elif name == "id":
                self.id.append(value)
            elif name == "duplicateId":
                self.duplicateId.append(value)
            elif name == "birn_annot:bamsID" :
                self.bamsID.append(value) 
            elif name == "birn_annot:bonfireID" :
                self.bonfireID.append(value) 
            elif name == "obo_annot:acronym":
                self.acronym.append(value)
            elif name == "obo_annot:synonym":
                self.synonym.append(value) 
            elif name == "parent":
                self.parent.append(value)
            elif name == "birn_annot:birnlexDefinition":
                self.definition.append(value)
            elif name == "core:definition":
                self.definition.append(value)
            elif name == "core:prefLabel":
                self.prefLabel.append(value)
            elif name == "obo_annot:nifID":
                self.nifID.append(value)
            elif name == "birn_annot:hasCurationStatus":
                self.curationStatus.append(value)
            elif name == "obo_annot:UmlsCui":
                self.umls.append(value)
            elif name == "rdfs:comment":
                self.comment.append(value)
            elif name == "birn_annot:neuronamesID":
                self.neuronamesID.append(value)
            elif name == "obo_annot:hasAbbrevSource":
                self.abbrevSource.append(value)
            elif name == "obo_annot:abbrev":
                self.abbrev.append(value)
            elif name == "obo_annot:definingCitation":
                self.definingCitation.append(value)
            elif name == "core:editorialNote":
                self.editorialNote.append(value)
            elif name == "obo_annot:externallySourcedDefinition":
                self.externallySourcedDefinition.append(value)
            elif name == "obo_annot:hasDefinitionSource":
                self.definitionSource.append(value)
            elif name == "obo_annot:modifiedDate":
                self.modifiedDate.append(value)
            elif name == "core:example":
                self.example.append(value)
            elif name == "birn_annot:hasBirnlexCurator":
                self.curator.append(value)
            elif name == "obo_annot:createdDate":
                self.createdDate.append(value)
            elif name == "birn_annot:ncbiTaxScientificName":
                self.taxName.append(value)
            elif name == "birn_annot:ncbiTaxID":
                self.taxID.append(value)
            elif name == "birn_annot:gbifTaxonKeyID":
                self.taxKey.append(value)
            elif name == "birn_annot:gbifID":
                self.gbifID.append(value)
            elif name == "obo_annot:misspelling":
                self.misspelling.append(value) 
            elif name == "birn_annot:itisID":
                self.itisID.append(value)
            elif name == "obo_annot:taxonomicCommonName":
                self.commonName.append(value)
                   
    def endElement(self, elName):
        if elName == 'leaf' and self.label != "":
    
            self.writeWikipediaPage()
	    self.writeRedirectIdPage()
            self.clearVars()

    #get the second part of the URI after the hash mark
    def stripURI(self, URI):
	splitArray = URI.split('#')
	return splitArray[1];

    def writeRedirectIdPage(self):
   
        p = wikipedia.Page(self.ow, self.id)
        h = ""
        
        for item in self.id:
            h += "#REDIRECT [[:Category:" + self.label + "]]"

        if p.exists() :
            existingText = p.get()
            if h.strip() == existingText.strip():
                print "Nothing to do!  Skipped page for ", self.label
            else:
		p.put(h, "updated by NifBot2")
                print "updated page for ", self.label
        else:
            p.put(h, "added by NifBot2")
            print "created page for ", self.label

    
    def writeWikipediaPage(self):
	
        p = wikipedia.Page(self.ow, "Category:" + self.label)
        h = ""
        
        for item in self.parent:
            h += "[[Category:" + item + "]]"
    
        for item in self.id:
            h += "\n\n* ID: [[id::" + item + "]]"
    
        for item in self.comment:
            h += "\n\n* Comment: [[comment::" + item + "]]" 
    
        for item in self.definition:
            h += "\n\n* Definition: [[definition::" + item + "]]"
    
        for item in self.synonym:
            h += "\n\n* Synonym: [[synonym::" + item + "]]"
    
        for item in self.neuronamesID:
            h += "\n\n* Neuro Names ID: [[neuronamesID::" + item + "| ]][[neuronamesLink::http://braininfo.rprc.washington.edu/Scripts/hiercentraldirectory.aspx?ID=" + item + "| " + item + "]]"
    
	for item in self.bamsID:
	    h += "\n\n* BAMS ID: [[bamsID::"+item+"| ]][[bamsLink::http://brancusi.usc.edu/bkms/brain/show-braing2.php?aidi="+item+"| "+item+"]]"

        for item in self.editorialNote:
            h += "\n\n* Editorial Note: [[editorialNote::" + item + "]]"
    
        for item in self.externallySourcedDefinition:
            h += "\n\n* Externally Sourced Definition: [[externallySourcedDefinition::" + item + "]]"
            
        for item in self.definitionSource:
            h += "\n\n* Definition Source: [[definitionSource::" + self.stripURI(item) + "]]"
    
        for item in self.definingCitation:
            h += "\n\n* Definition Citation: [[definingCitation::" + item + "]]"
            
        for item in self.umls:
            if item != "":
                h += "\n\n* UMLSCUI: [[umlscui::" + item + "]]"
            
        for item in self.acronym:
            h += "\n\n* Acronym: [[acronym::" + item + "]]"
            
        for item in self.abbrev:
            h += "\n\n* Abbreviation: [[abbrev::" + item + "]]"
            
        for item in self.abbrevSource:
            h += "\n\n* Abbreviation Source: [[abbrevSource::" + self.stripURI(item) + "]]"
            
        #for item in self.modifiedDate:
        #   h += "\n\n* Modified Date: [[modifiedDate::" + item + "]]"
            
        for item in self.curationStatus :
            h += "\n\n* Curation Status: [[curationStatus::" + self.stripURI(item) + "]]"
            
        for item in self.example:
            h += "\n\n* Example: [[example::" + item + "]]"
            
        #for item in self.curator:
        #    h += "\n\n* Curator: [[curator::" + self.stripURI(item) + "]]"
        
        for item in self.createdDate:
            h += "\n\n* Created Date: [[created::" + item + "]]"
            
        for item in self.taxName:
            h += "\n\n* NCBI Taxonomic Scientific Name: [[taxName::" + item + "]]"
            
        for item in self.taxID:
            h += "\n\n* NCBI Taxonomic ID: [[taxID::" + item + "]]"
        
        for item in self.taxKey:
            h += "\n\n* GBIF Taxonomic Key ID: [[taxKey::" + item + "]]"
            
        for item in self.gbifID:
            h += "\n\n* GBIF ID: [[gbifID::" + item + "]]"
            
        for item in self.misspelling: 
            h += "\n\n* Common Misspelling: [[misspelling::" + item + "]]"
            
        for item in self.itisID:
            h += "\n\n* ITIS ID: [[itisID::" + item + "]]"
            
        for item in self.commonName:
            h += "\n\n* Taxonomic Common Name: [[commonName::" + item + "]]"

        for item in self.duplicateId:
            h += "\n\n==Duplicates=="
            h += "\n\n* This item is duplicated with: [" + item + "]"

	h += "\n\n==Query for more information=="
	queryString = self.label.replace(" ", "%20")
        queryString = queryString.replace("_", "%20")
	h += "\n[http://nif-apps-stage.neuinfo.org/search?query=%22" + queryString + "%22 Click here to find more about " + self.label.replace("_", " ") + "]"

        if p.exists() :
            existingText = p.get()
            if h.strip() == existingText.strip():
                print "Nothing to do!  Skipped page for ", self.label
            else:
		print "Starting update!"
		self.updatePage(p, h)
                print "updated page for ", self.label
        else:
            p.put(h, "added by NifBot2")
            print "created page for ", self.label
            
    def updatePage(self, p, h):
        
    	currentRevision = p.get()

        print "********Current Version of ", p.title()
        print currentRevision.strip()

	lastNifBotRevision = ''

	for history in p.getVersionHistory():
            # find the most recent revision by NifBot
	    if history[2] == "NifBot":
	    	lastNifBotRevision = p.getOldVersion(history[0])
		break

	# if there was no original NifBotRevision, flag it and quit
	if lastNifBotRevision == '':
	    print "COULD NOT FIND A PREVIOUS NIF BOT REVISION FOR ", p.title()
	    exit

	#write out the newest version, the last NifBot version, and the new version
	# to the file system
	FILE1 = open("lastNifBotRevision.txt", "w")
	FILE1.writelines(lastNifBotRevision)
	FILE1.close()

	FILE2 = open("currentRevision.txt", "w")
	FILE2.writelines(currentRevision)
	FILE2.close()

	FILE3 = open("newRevision.txt", "w")
	FILE3.writelines(h)
	FILE3.close()

	#run diff3 on these three files to see if there will be conflicts.
	cmd = "diff3 -E newRevision.txt lastNifBotRevision.txt currentRevision.txt"

	# http://docs.python.org/library/subprocess.html
        p1 = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True)
	revisionChanges = p1.communicate()[0]
	
	if revisionChanges == '':
	    print "\n****SUCCESSFUL MERGE... NO MAJOR CONFLICTS"

	    #this call to diff3 actually does the merge
	    cmd = "diff3 -m newRevision.txt lastNifBotRevision.txt currentRevision.txt"

	    # http://docs.python.org/library/subprocess.html
            p2 = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True)
	    mergedNewRevision = p2.communicate()[0]

	    print "******SAVING THIS VERSION TO THE WIKI:"
            print mergedNewRevision

	    #actually generate the content that you are going to save to the wiki, including the conflict statements.	
            p.put(mergedNewRevision, "updated by NifBot")

	else :
	    #if the output from this diff is non-zero, log the diff as a conflict for
	    # later manual inspection
            print "\n*****MERGE FOR " + p.title() + "HAD CONFLICTS.  CONFLICTS FOLLOW:\n"
	    print revisionChanges	    
            
    def clearVars(self):
        self.label = ""
        self.parent = list()
        self.id = list)(
        self.duplicateId = list()
        self.bamsID = list()
        self.bonfireID = list()
        self.acronym = list()
        self.synonym = list()
        self.modifiedDate = list()
        self.definition = list()
        self.prefLabel = list()
        self.nifID = list()
        self.curationStatus = list() 
        self.comment = list()
        self.umls = list()
        self.neuronamesID = list()
        self.abbrevSource = list()
        self.abbrev = list()
        self.definingCitation = list()
        self.editorialNote = list()
        self.externallySourcedDefinition = list()
        self.definitionSource = list()
        self.example = list()
        self.curator = list()
        self.createdDate = list()
        self.taxName = list()
        self.taxID = list()
        self.taxKey = list()
        self.gbifID = list()
        self.misspelling = list()
        self.itisID = list()
        self.commonName = list()

if __name__ == '__main__':
    print "PRINT TEST"
    # Create a parser
    parser = make_parser()
    
    # Tell parser we are not interested in XML namespaces
    parser.setFeature(feature_namespaces, 0)
    
    # Create the handler
    dh = WriteWikipediaFromTreeML()
    
    #Tell the parser to use our handler
    parser.setContentHandler(dh)

    #inform the log that we are ready to go!
    print "STARTING UPDATE!"
    
    #parse the input
    parser.parse("NIF-tree.xml")
    
    wikipedia.stopme()

#unchanged = list()   # in order to safe those that already have a page

