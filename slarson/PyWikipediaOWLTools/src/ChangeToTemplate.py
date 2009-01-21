import wikipedia, login, category, string

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

# Define the main function
def main():
    site = wikipedia.Site('en', 'nif')
    login.LoginManager('bot', 'NifBot', site)
    # site = wikipedia.getSite()

    startpage = '!'
    for page in site.allpages(startpage): # Use a generetor object, this will yield all pages one by one
        pagename = page.title() # Take the title of the page (not "[[page]]" but "page")
        wikipedia.output(u"Loading %s..." % pagename) # Please, see the "u" before the text
        try:
            text = page.get() # Taking the text of the page
        except wikipedia.NoPage: # First except, prevent empty pages
            text = ''
	except pagename.startswith("Category") == False # second except, prevent non-category pages
	    text = ''
        except wikipedia.IsRedirectPage: # second except, prevent redirect
            wikipedia.output(u'%s is a redirect!' % pagename)
            continue
        except wikipedia.Error: # third exception, take the problem and print
            wikipedia.output(u"Some error, skipping..")
            continue     
	
	newText = processOldText(text)

        wikipedia.output(newText) # Print the output, encoding it with wikipedia's method
 
if __name__ == '__main__':
    try:
        main()
    finally:
        wikipedia.stopme()

def processOldText(text):

    lineList = text.splitlines() #break lines apart
    betterLineList = list()
    unrecognizedLineList = list()

    #transform recognized lines
    for line in lineList:
	if recognized(line):
	    betterLine = transform(line)
	    betterLineList.append(betterLine)
	else:
	    print "unrecognized line in page " + pagename + ": " + line
	    unrecognizedLineList.append(line)

    newText = "{{NIF Standard"
    for betterLine in betterLineList:
	newText += betterLine
    newText += "}}"

    #newText += unrecognizedLineList

    #newText += category

    return newText

def recognized(line):

    L = ["[[id::", "[[comment::", "[[definition::", "[[synonym::",
    "[[neuronamesID::", "[[neuronamesLink::http://braininfo.rprc.washington.edu/Scripts/hiercentraldirectory.aspx?ID=", 
    "[[editorialNote::", "[[externallySourcedDefinition::", "[[definitionSource::", "[[definingCitation::", 
    "[[umlscui::", "[[acronym::", "[[abbrev::", "[[abbrevSource::", "[[modifiedDate::", "[[curationStatus::", 
    "[[example::", "[[curator::", "[[created::", "[[taxName::", "[[taxID::", "[[taxKey::", "[[gbifID::", 
    "[[misspelling::", "[[itisID::", "[[commonName::"]

    for item in L:
        if line.find(item) > -1:
            return True
    return False

def transform(line):

    #do some regexp magic
    #return transformed string

##################

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
     