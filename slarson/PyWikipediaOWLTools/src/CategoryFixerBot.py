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
    hasDash = words[0].find("-")
    if hasDash:
        words[0] = words[0][0:hasDash+1] + words[0][hasDash+1].upper() + words[0][hasDash+1:]

    newVersion = ""
    for word in words:
        newVersion += word + " "
    
    newVersion = newVersion.rstrip()
    
    if testPageExistance(newVersion):
        return newVersion


    words = allCapsVersion.split()
    words[0] = words[0].upper()

    newVersion = ""
    for word in words:
        newVersion += word + " "
    
    newVersion = newVersion.rstrip()
    
    if testPageExistance(newVersion):
        return newVersion

    words = allCapsVersion.split()
    if len(words) > 2:
        words[0] = words[0][0:-4] + words[0][-4:].upper()
        words[1] = words[1].lower()

    for i in range(2,len(words)):
        words[i] = words[i].lower()

    newVersion = ""
    for word in words:
        newVersion += word + " "
    
    newVersion = newVersion.rstrip()
    
    if testPageExistance(newVersion):
        return newVersion

    words = allCapsVersion.split()
    if len(words) > 1:
        words[0] = words[0][0:-2] + words[0][-2:].upper()

    for i in range(1,len(words)):
        words[i] = words[i].lower()

    newVersion = ""
    for word in words:
        newVersion += word + " "
    
    newVersion = newVersion.rstrip()
    
    if testPageExistance(newVersion):
        return newVersion

    words = allCapsVersion.split()
    if len(words) > 1:
        words[0] = words[0][0:-3] + words[0][-3:].upper()

    for i in range(1,len(words)):
        words[i] = words[i].lower()

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

