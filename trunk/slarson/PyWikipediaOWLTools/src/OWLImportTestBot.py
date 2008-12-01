#from rdflib import Graph, URIRef, Literal, Namespace, RDF
import wikipedia, login, category


#import java.util.ArrayList
#import edu.stanford.smi.protege.model.Cls
#import edu.stanford.smi.protege.model.Project
#import edu.stanford.smi.protege.model.Slot
#import edu.stanford.smi.protege.ui.ProjectManager
#import edu.stanford.smi.protege.util.ApplicationProperties
#import edu.stanford.smi.protegex.owl.ProtegeOWL
#import edu.stanford.smi.protegex.owl.jena.JenaOWLModel
#import edu.stanford.smi.protegex.owl.repository.RepositoryManager
#import edu.stanford.smi.protegex.owl.repository.impl.LocalFolderRepository
#import edu.stanford.smi.protegex.owl.ui.subsumption.AssertedSubsumptionTreePanel
#import edu.stanford.smi.protegex.owl.ui.subsumption.SubsumptionTreeNode
#import edu.stanford.smi.protegex.owl.ui.subsumption.SubsumptionTreeRoot

#family = "ontoworld" # note that you need to setup the appropriate family file

#i = Graph()

#i.bind("foaf", "http://xmlns.com/foaf/0.1/")
#RDF = Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
#RDFS = Namespace("http://www.w3.org/2000/01/rdf-schema#")
#FOAF = Namespace("http://xmlns.com/foaf/0.1/")
#i.load("eswc.rdf")



ow = wikipedia.Site('en', 'nif')
login.LoginManager('bot', 'NifBot', ow)

p = wikipedia.Page(ow, "Category:Neuron")
if p.exists():
    print "there is a category neuron page"
else :
    p.put("This is an automatically created page", "added by NifBot")
    print "created page"

#unchanged = list()   # in order to safe those that already have a page

# iterates through everything that has the type Person
# (note, only explicit assertions -- rdflib does not do reasoning here!)
#for s in i.subjects(RDF["type"], FOAF["Person"]):
#        for n in i.objects(s, FOAF["name"]):  # reads the name
#            p = wikipedia.Page(ow,n)          # gets the page with that name
#            if p.exists():
#                unchanged.append(n)
#            else: # create the instantiated template
#                h = '{{Person|' +  '\n'
#                h  = ' Name=' + n
#                
#                for hp in i.objects(s, FOAF["workplaceHomepage"]):
#                    h  = '|' +  '\n'
#                    hp = hp[7:]
#                    h  = ' Homepage='  + hp
#                    if len(hp)>23: # if the name of the page is too long,
#                        h  = '|'  + '\n'
#                        if hp.find("/"): # make something shorter
#                            hp = hp[0:hp.find("/")]
#                        h  = ' Homepage label= at '  + hp

#                for hp in i.objects(s, RDFS["seeAlso"]):
#                    h  = '|' +  '\n'
#                    h  = ' FOAF=' + hp
#                h  = '\n' +  '}}' # end Person template

                # write a sentence
#                h  = '\n' +  "'''"  + n +  "''' attended the [[delegate at::ESWC2006]]."

                # add a category
 #               h  = '\n' +  '\n' +  '[[Category:Person]]'
 #               print n  + ' changed'
 #               p.put(h, 'Added from ontology')

wikipedia.stopme()
#print unchanged