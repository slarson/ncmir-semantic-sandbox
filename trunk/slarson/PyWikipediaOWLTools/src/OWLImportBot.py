#from rdflib import Graph, URIRef, Literal, Namespace, RDF
import wikipedia, login, category, string

from xml.sax import saxutils
from xml.sax import make_parser
from xml.sax.handler import feature_namespaces
from xml.sax.handler import ContentHandler

#Reads a TreeML processed version of the NIFSTD ontology and writes classes
# to openccdb.org/ontowiki.  The TreeML is too large to be loaded into memory, so
# it is processed using a sax parser.
# Tests to see if current page would be changed before updating.
class WriteWikipediaFromTreeML(ContentHandler):
    
    def __init__(self):
        self.clearVars()
        self.ow = wikipedia.Site('en', 'nif')
        login.LoginManager('bot', 'NifBot', self.ow)
        self.unchanged = list()
        
    def startElement(self, elName, attrs):
       
        if elName == 'attribute': 
        
            # look for the name and value attributes 
            name = attrs.get('name', None)
            value = attrs.get('value', None)
            
            if name == "label" :
                self.label = value
            elif name == "id":
                self.id.append(value)
            elif name == "birn_annot:bonfireID" :
                self.bonfireID.append(value) 
            elif name == "j.0:acronym":
                self.acronym.append(value)
            elif name == "j.0:synonym":
                self.synonym.append(value) 
            elif name == "parent":
                self.parent.append(value)
            elif name == "birn_annot:birnlexDefinition":
                self.definition.append(value)
            elif name == "sao:definition":
                self.definition.append(value)
            elif name == "j.2:prefLabel":
                self.prefLabel.append(value)
            elif name == "j.0:nifID":
                self.nifID.append(value)
            elif name == "birn_annot:hasCurationStatus":
                self.curationStatus.append(value)
            elif name == "j.0:UmlsCui":
                self.umls.append(value)
            elif name == "rdfs:comment":
                self.comment.append(value)
            elif name == "birn_annot:neuronamesID":
                self.neuronamesID.append(value)
            elif name == "j.0:hasAbbrevSource":
                self.abbrevSource.append(value)
            elif name == "j.0:abbrev":
                self.abbrev.append(value)
            elif name == "j.0:definingCitation":
                self.definingCitation.append(value)
            elif name == "j.2:editorialNote":
                self.editorialNote.append(value)
            elif name == "j.0:externallySourcedDefinition":
                self.externallySourcedDefinition.append(value)
            elif name == "j.0:hasDefinitionSource":
                self.definitionSource.append(value)
            elif name == "j.0:modifiedDate":
                self.modifiedDate.append(value)
            elif name == "j.2:example":
                self.example.append(value)
            elif name == "birn_annot:hasBirnlexCurator":
                self.curator.append(value)
            elif name == "j.0:createdDate":
                self.createdDate.append(value)
            elif name == "birn_annot:ncbiTaxScientificName":
                self.taxName.append(value)
            elif name == "birn_annot:ncbiTaxID":
                self.taxID.append(value)
            elif name == "birn_annot:gbifTaxonKeyID":
                self.taxKey.append(value)
            elif name == "birn_annot:gbifID":
                self.gbifID.append(value)
            elif name == "j.0:misspelling":
                self.misspelling.append(value) 
            elif name == "birn_annot:itisID":
                self.itisID.append(value)
            elif name == "j.0:taxonomicCommonName":
                self.commonName.append(value)
        
        elif ((elName == 'branch') or (elName == 'leaf')) and (self.label != ""):
            self.writeWikipediaPage()
            self.clearVars()
            
    def endElement(self, elName):
        if elName == 'leaf' and self.label != "":
            
            self.writeWikipediaPage()
            self.clearVars()
          
    def writeWikipediaPage(self):
        
        p = wikipedia.Page(self.ow, "Category:" + self.label)
        #if p.exists():
        #    print "there is a category ", self.label, " page"
        #    self.unchanged.append(self.label)
        #else :
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
            h += "\n\n* Neuro Names ID: [[neuronamesID::" + item + "]]"
            h += "\n\n* Neuro Names Link: [[neuronamesLink::http://braininfo.rprc.washington.edu/Scripts/hiercentraldirectory.aspx?ID=" + item + "]]"
    
        for item in self.editorialNote:
            h += "\n\n* Editorial Note: [[editorialNote::" + item + "]]"
    
        for item in self.externallySourcedDefinition:
            h += "\n\n* Externally Sourced Definition: [[externallySourcedDefinition::" + item + "]]"
            
        for item in self.definitionSource:
            h += "\n\n* Definition Source: [[definitionSource::" + item + "]]"
    
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
            h += "\n\n* Abbreviation Source: [[abbrevSource::" + item + "]]"
            
        for item in self.modifiedDate:
           h += "\n\n* Modified Date: [[modifiedDate::" + item + "]]"
            
        for item in self.curationStatus :
            h += "\n\n* Curation Status: [[curationStatus::" + item + "]]"
            
        for item in self.example:
            h += "\n\n* Example: [[example::" + item + "]]"
            
        for item in self.curator:
            h += "\n\n* Curator: [[curator::" + item + "]]"
        
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

        print "New Version:"
        print h.strip();
        if p.exists() :
            existingText = p.get()
            print "Current Version:"
            print existingText.strip()
            if h.strip() == existingText.strip():
                print "Nothing to do!  Skipped page for ", self.label
            else:
                p.put(h, "updated by NifBot")
                print "updated page for ", self.label
        else:
            p.put(h, "added by NifBot")
            print "created page for ", self.label
            
            
    def clearVars(self):
        self.label = ""
        self.parent = list()
        self.id = list()
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
    # Create a parser
    parser = make_parser()
    
    # Tell parser we are not interested in XML namespaces
    parser.setFeature(feature_namespaces, 0)
    
    # Create the handler
    dh = WriteWikipediaFromTreeML()
    
    #Tell the parser to use our handler
    parser.setContentHandler(dh)
    
    #parse the input
    parser.parse("NIF-tree.xml")
    
    wikipedia.stopme()

#unchanged = list()   # in order to safe those that already have a page

