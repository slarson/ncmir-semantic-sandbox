import sys

sys.path.append("../../pywikipedia/")
sys.path.append("../../pywikipedia/userinterfaces")
sys.path.append("../../pywikipedia/families")
sys.path.append("families")

import wikipedia, login, category, string
import urllib2

from BeautifulSoup import BeautifulStoneSoup

###########################
# Crawls the Neurolex pages 
# and transforms them into 
# the NIF Standard template form
# (http://neurolex.org/wiki/Template:NIF_Standard)
#
# 12/11/08
# slarson@ncmir.ucsd.edu
###########################

#Note: need to special case the Category line. "[[Category:"
#Note: need to figure out how to deal with unrecognized lines


def processOldText(pagename):
    # grab RDF from NeuroLex
    xml = urllib2.urlopen("http://neurolex.org/wiki/Special:ExportRDF/:"+pagename)

    # parse the XML
    #soup = BeautifulStoneSoup(xml, convertEntities=BeautifulStoneSoup.XML_ENTITIES)
    soup = BeautifulStoneSoup(xml)

    # grab elements out of the parsed XML
    externallysourceddefinition = soup.find("owl:class").find("property:externallysourceddefinition")
    if externallysourceddefinition:
        return externallysourceddefinition.prettify()

    # eventually...
    # rewrite the grabbed elements as members of a template.
    #

    return soup.find("owl:class").prettify()

def writeChanges(p):
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
        

# Define the main function
def main():

    # get a handle to the site object
    site = wikipedia.Site('en', 'nif')

    # do a log in
    login.LoginManager('bot', 'NifBot', site)

    # Use a generator object, this will yield all category pages
    for page in site.categories(1000): 

        # Take the title of the page (not "[[page]]" but "page")
        pagename = page.title() 

        # Please, see the "u" before the text
        wikipedia.output(u"Loading %s..." % pagename) 
        
        #skip this page if it isn't a category page
        if pagename.startswith("Category") == False:
            continue

        try:
            text = page.get() # Taking the text of the page
        except wikipedia.NoPage: # First except, prevent empty pages
            wikipedia.output(u'%s no page found!' % pagename)
            continue
        except wikipedia.IsRedirectPage: # prevent redirect
            wikipedia.output(u'%s is a redirect!' % pagename)
            continue
        except wikipedia.Error: # take the problem and print
            wikipedia.output(u"Some error, skipping..")
            continue     
	
	newtext = processOldText(pagename)

        wikipedia.output(newtext) # Print the output, encoding it with wikipedia's method
 
if __name__ == '__main__':
    try:
        main()
    finally:
        wikipedia.stopme()
