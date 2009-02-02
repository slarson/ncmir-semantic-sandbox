#from rdflib import Graph, URIRef, Literal, Namespace, RDF
import sys
import subprocess

sys.path.append("../../pywikipedia/")
sys.path.append("../../pywikipedia/userinterfaces")
sys.path.append("../../pywikipedia/families")
sys.path.append("families")

import wikipedia, login, string

def array_size_compare(x, y):

    if len(x) > len(y):
        return 1
    elif len(x) == len(y):
        return 0
    else : # len(x) < len(y)
        return -1


# open file handle for list of wanted categories        
FILE1 = open("wantedCategories.txt")

# create a list of all the lines in the file
fileList = FILE1.readlines()

# open a file to write  the capitalized versions
# of the wanted categories
FILE_OUT = open("capitalizedWantedCategories.txt", "w")

finalWordsList = list()

# go through each category line and parse
# out the category names
for fileLine in fileList:

    # split the line at the spaces
    words = fileLine.split()

    # take the words between the first one
    # and leave out the last two
    words = words[1:-2]

    # if there is only one word, skip
    # since we only have a problem with multi-word
    # categories
    if (len(words) < 2):
        continue

    # capitalize each word in the string, while
    # keeping track of the uncapitalized version
    outStringCaps = ""
    outStringNoCaps = ""
    for word in words:
        outStringCaps += word.capitalize() + " "
        outStringNoCaps += word + " "
        
        
    #write the two versions to the outgoing file
    finalWordsList.append(outStringCaps)

finalWordsList = sorted(finalWordsList, array_size_compare)

for finalWord in finalWordsList:
    FILE_OUT.write(finalWord + "\n")

FILE1.close()
FILE_OUT.close()

