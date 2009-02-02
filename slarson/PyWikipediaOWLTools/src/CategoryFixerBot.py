import sys
import subprocess

sys.path.append("../../pywikipedia/")
sys.path.append("../../pywikipedia/userinterfaces")
sys.path.append("../../pywikipedia/families")
sys.path.append("families")

import wikipedia, login, string, category

# This script runs through a list of category names
# and tries to fix those names that have been
# improperly set to the lowercased version.
# Uses pywikipediabot to fix the affected pages
# author: Stephen D. Larson (slarson@ncmir.ucsd.edu

def findCapsVersion(allCapsVersion):

    words = allCapsVersion.split()
    words[0] = words[0][0:-1] + words[0][-1].upper()
    words[1] = words[1].lower()
    

    newVersion = ""
    for word in words:
        newVersion += word + " "
    
    newVersion = newVersion.rstrip()
    
    if testPageExistance(newVersion):
        return newVersion

    return False
        
    
def testPageExistance(capsVersion):
    # get a handle on a page by that name
    p = wikipedia.Page(ow, "Category:" + capsVersion)

    return p.exists()

def moveCategory(capsVersion):
    catMove = category.CategoryMoveRobot(capsVersion.lower(), capsVersion, editSummary='replaced category with appropriately named category')
    catMove.run()

ow = wikipedia.Site('en', 'nif')
login.LoginManager('bot', 'NifBot', ow)

wikipedia.put_throttle.setDelay(1, absolute = True)

# open file handle for list of wanted categories        
FILE1 = open("capitalizedWantedCategories.txt")

# create a list of all the lines in the file
fileList = FILE1.readlines()

# go through each category line
for fileLine in fileList:

    origCapsVersion = fileLine

    print "looking up category for ", origCapsVersion

    capsVersion = findCapsVersion(origCapsVersion)    

    if capsVersion:
        print "found ", capsVersion
        moveCategory(capsVersion.rstrip())
    else:
        print "Did not find appropriate caps version ", origCapsVersion
        

FILE1.close()

