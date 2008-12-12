import sys
sys.path.append("../../pywikipedia/")
sys.path.append("../../pywikipedia/userinterfaces")
sys.path.append("../../pywikipedia/families")
sys.path.append("families")


import wikipedia, login, category

#####################################
# Script just intended to make sure that the bot setup is working appropriately
# slarson@ncmir.ucsd.edu
# 11/30/08
#####################################

ow = wikipedia.Site('en', 'nif')
login.LoginManager('bot', 'NifBot', ow)

p = wikipedia.Page(ow, "Category:Neuron")
if p.exists():
    print "there is a category neuron page"
else :
    p.put("This is an automatically created page", "added by NifBot")
    print "created page"

#unchanged = list()   # in order to safe those that already have a page

wikipedia.stopme()
#print unchanged