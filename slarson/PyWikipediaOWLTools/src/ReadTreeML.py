
from xml.sax import saxutils
from xml.sax import make_parser
from xml.sax.handler import feature_namespaces
from xml.sax.handler import ContentHandler


class PrintCSVFromTreeML(ContentHandler):
    
    def __init__(self):
        self.clearVars()
    
        print "label, parent, id, birn_annot:bonfireID, obo_annot:acronym, obo_annot:synonym, birn_annot:birnlexDefinition, core:prefLabel, obo_annot:nifID, birn_annot:hasCurationStatus"
        
    def startElement(self, elName, attrs):
       
        if elName == 'attribute': 
        
            # look for the name and value attributes 
            name = attrs.get('name', None)
            value = attrs.get('value', None)
            
            if name == "label" :
                print
                self.label = value
            elif name == "id":
                self.id = value
            elif name == "birn_annot:bonfireID" :
                self.bonfireID = value 
            elif name == "j.0:acronym":
                self.acronym = value
            elif name == "j.0:synonym":
                self.synonym = value 
            elif name == "parent":
                self.parent = value
            elif name == "birn_annot:birnlexDefinition":
                self.definition = value
            elif name == "j.2:prefLabel":
                self.prefLabel = value
            elif name == "j.0:nifID":
                self.nifID = value
            elif value == "birn_annot:hasCurationStatus":
                self.curationStatus = value
        
        elif ((elName == 'branch') or (elName == 'leaf')) and (self.label != ""):
            self.printCSVLine()
            self.clearVars()
            
    def endElement(self, elName):
        if elName == 'leaf' and self.label != "":
            
            self.printCSVLine()
            self.clearVars()
          
    def printCSVLine(self):
        print self.label, ", ", self.parent, ", ", self.id, ", ", self.bonfireID, ", ", self.acronym, ", ", self.synonym, ", ", self.definition, ", ",self.prefLabel, ", ", self.nifID, ", ", self.curationStatus
            
    def clearVars(self):
        self.label = ""
        self.parent = ""
        self.id = ""
        self.bonfireID = ""
        self.acronym = ""
        self.synonym = ""
        self.modifiedDate = ""
        self.definition = ""
        self.prefLabel = ""
        self.nifID = ""
        self.curationStatus = "" 
        

if __name__ == '__main__':
    # Create a parser
    parser = make_parser()
    
    # Tell parser we are not interested in XML namespaces
    parser.setFeature(feature_namespaces, 0)
    
    # Create the handler
    dh = PrintCSVFromTreeML()
    
    #Tell the parser to use our handler
    parser.setContentHandler(dh)
    
    #parse the input
    parser.parse("NIF-tree.xml")