#!/usr/bin/python
# -*- coding: utf-8	 -*-
"""
This utility's primary use is to find all mismatches between the namespace
naming in the family files and the language files on the wiki servers.

If the -all parameter is used, it runs through all known languages in a family.

-langs and -families parameters may be used to check comma-seperated languages/families.

If the -wikimedia parameter is used, all Wikimedia families are checked.

Examples:

    python testfamily.py -family:wiktionary -lang:en

    python testfamily.py -family:wikipedia -all -log:logfilename.txt

    python testfamily.py -families:wikipedia,wiktionary -langs:en,fr

    python testfamily.py -wikimedia -all

"""
#
# (C) Yuri Astrakhan, 2005
#
# Distributed under the terms of the MIT license.
#
__version__ = '$Id: testfamily.py 5024 2008-02-15 16:59:07Z rotem $'
#

import sys, wikipedia, traceback


#===========

def testSite(site):
    try:
        wikipedia.getall(site, [wikipedia.Page(site, 'Any page name')])
    except KeyboardInterrupt:
        raise
    except wikipedia.NoSuchSite:
        wikipedia.output( u'No such language %s' % site.lang )
    except:
        wikipedia.output( u'Error processing language %s' % site.lang )
        wikipedia.output( u''.join(traceback.format_exception(*sys.exc_info())))

def main():
    all = False
    language = None
    fam = None
    wikimedia = False
    for arg in wikipedia.handleArgs():
        if arg == '-all':
            all = True
        elif arg[0:7] == '-langs:':
            language = arg[7:]
        elif arg[0:10] == '-families:':
            fam = arg[10:]
        elif arg[0:10] == '-wikimedia':
            wikimedia = True

    mySite = wikipedia.getSite()
    if language is None:
        language = mySite.lang
    if wikimedia:
        families = ['wikipedia', 'wiktionary', 'wikiquote', 'wikisource', 'wikibooks', 'wikinews', 'wikiversity', 'meta', 'commons', 'mediawiki', 'species', 'incubator', 'test']
    elif fam is not None:
        families = fam.split(',')
    else:
        families = [mySite.family.name,]

    for family in families:
        try:
            fam = wikipedia.Family(family)
        except ValueError:
            wikipedia.output(u'No such family %s' % family)
            continue
        if all:
            for lang in fam.langs.iterkeys():
                testSite(wikipedia.getSite(lang, family))
        else:
            languages = language.split(',')
            for lang in languages:
                try:
                    testSite(wikipedia.getSite(lang, family))
                except wikipedia.NoSuchSite:
                    wikipedia.output(u'No such language %s in family %s' % (lang, family))

if __name__ == "__main__":
    try:
        main()
    finally:
        wikipedia.stopme()
