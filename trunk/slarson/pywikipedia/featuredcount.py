#!/usr/bin/python
# -*- coding: utf-8 -*-
"""
This script only counts how many have featured articles all wikipedias.

usage: featuredcount.py

"""
__version__ = '$Id: featured.py 4811 2008-01-05 16:22:45Z leogregianin $'

#
# Distributed under the terms of the MIT license.
#

import sys
import wikipedia, catlib
from featured import featured_name

def featuredArticles(site):
    method=featured_name[site.lang][0]
    name=featured_name[site.lang][1]
    args=featured_name[site.lang][2:]
    raw=method(site, name, *args)
    arts=[]
    for p in raw:
        if p.namespace()==0:
            arts.append(p)
        elif p.namespace()==1:
            arts.append(wikipedia.Page(p.site(), p.titleWithoutNamespace()))
    wikipedia.output('\03{lightred}** wikipedia:%s has %i featured articles\03{default}' % (site.lang, len(arts)))
    
if __name__=="__main__":
    mysite=wikipedia.getSite()
    fromlang=featured_name.keys()
    fromlang.sort()
    try:
        for ll in fromlang:
            fromsite=wikipedia.Site(ll)
            if not fromsite==wikipedia.getSite():
                arts=featuredArticles(fromsite)
        arts_mysite=featuredArticles(mysite)
    finally:
        wikipedia.stopme()
