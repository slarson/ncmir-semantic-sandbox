import sys
import subprocess

sys.path.append("../../pywikipedia/")
sys.path.append("../../pywikipedia/userinterfaces")
sys.path.append("../../pywikipedia/families")
sys.path.append("families")

import wikipedia, login, string, category

def findCapsVersion(allCapsVersion):
    if testPageExistance(allCapsVersion):
        return allCapsVersion


    words = allCapsVersion.split()
    words[0] = words[0].upper()
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
    category.CategoryMoveRobot(capsVersion.lower(), capsVersion, editSummary='replaced category with appropriately named category')
    

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
        moveCategory(capsVersion)
    else:
        print "Did not find appropriate caps version ", origCapsVersion
        

FILE1.close()
