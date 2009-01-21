import sys
import subprocess
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

    currentRevision = p.get()
    lastNifBotRevision = ''

    for history in p.getVersionHistory():
        # find the most recent revision by NifBot
        if history[2] == "NifBot":
	    lastNifBotRevision = p.getOldVersion(history[0])
	    break

    # if there was no original NifBotRevision, flag it and quit
    if lastNifBotRevision == '':
	print "COULD NOT FIND A PREVIOUS NIF BOT REVISION FOR " . p.title()
	exit

    #write out the newest version, the last NifBot version, and the new version
    # to the file system
    FILE1 = open("lastNifBotRevision.txt", "w")
    FILE1.writelines(lastNifBotRevision)
    FILE1.close()

    FILE2 = open("currentRevision.txt", "w")
    FILE2.writelines(currentRevision)
    FILE2.close()

    #run diff3 on these three files so that their changes can be merged.
    #cmd = 'diff3 -E newRevision.txt lastNifBotRevision.txt  currentRevision.txt'
    #subprocess.Popen(cmd)
    
    #if the output from this diff is non-zero, log the diff as a conflict for
    # later manual inspection

    #cmd = 'diff3 -m newRevision.txt lastNifBotRevision.txt  currentRevision.txt'
    #subprocess.Popen(cmd)
    #actually generate the content that you are going to save to the wiki, including the conflict statements.
        
else :
    p.put("This is an automatically created page", "added by NifBot")
    print "created page"

#unchanged = list()   # in order to safe those that already have a page

wikipedia.stopme()
#print unchanged