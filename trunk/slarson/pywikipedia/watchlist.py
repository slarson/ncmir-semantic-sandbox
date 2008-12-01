# -*- coding: utf-8 -*-
"""
Allows access to the bot account's watchlist.

The function refresh() downloads the current watchlist and saves
it to disk. It is run automatically when a bot first tries to save a page
retrieved via XML Export. The watchlist can be updated manually by running
this script. The list will also be reloaded automatically once a month.

Syntax: python watchlist [-all]

Command line options:
    -all  -  Reloads watchlists for all wikis where a watchlist is already
             present
"""

# (C) Daniel Herding, 2005
#
# Distributed under the terms of the MIT license.

__version__='$Id: watchlist.py 5012 2008-02-12 15:23:38Z rotem $'

import wikipedia
import re, sys, pickle
import os.path
import time

cache = {}

def get(site = None):
    if site is None:
        site = wikipedia.getSite()
    if cache.has_key(site):
        # Use cached copy if it exists.
        watchlist = cache[site]
    else:
        fn = wikipedia.config.datafilepath('watchlists',
                  'watchlist-%s-%s.dat' % (site.family.name, site.lang))
        try:
            # find out how old our saved dump is (in seconds)
            file_age = time.time() - os.path.getmtime(fn)
            # if it's older than 1 month, reload it
            if file_age > 30 * 24 * 60 * 60:
                print 'Copy of watchlist is one month old, reloading'
                refresh(site)
        except OSError:
            # no saved watchlist exists yet, retrieve one
            refresh(site)
        f = open(fn, 'r')
        watchlist = pickle.load(f)
        f.close()
        # create cached copy
        cache[site] = watchlist
    return watchlist

def isWatched(pageName, site=None):
    watchlist = get(site)
    return pageName in watchlist
    
def refresh(site):
    # get watchlist special page's URL
    path = site.watchlist_address()
    print 'Retrieving watchlist for %s' % repr(site)
    #wikipedia.put_throttle() # It actually is a get, but a heavy one.
    watchlistHTML = site.getUrl(path)

    print 'Parsing watchlist'
    watchlist = []
    itemR = re.compile(r'<li><input type="checkbox" name="id\[\]" value="(.+?)" />')
    for m in itemR.finditer(watchlistHTML):
        pageName = m.group(1)
        watchlist.append(pageName)
    # Save the watchlist to disk
    # The file is stored in the watchlists subdir. Create if necessary.
    f = open(wikipedia.config.datafilepath('watchlists',
                 'watchlist-%s-%s.dat' % (site.family.name, site.lang)), 'w')
    pickle.dump(watchlist, f)
    f.close()

def refresh_all():
    import dircache, time
    filenames = dircache.listdir(wikipedia.config.datafilepath('watchlists'))
    watchlist_filenameR = re.compile('watchlist-([a-z\-:]+).dat')
    for filename in filenames:
        match = watchlist_filenameR.match(filename)
        if match:
            arr = match.group(1).split('-')
            family = arr[0]
            lang = '-'.join(arr[1:])
            site = wikipedia.getSite(code = lang, fam = family)
            refresh(site)

def main():
    all = False
    for arg in wikipedia.handleArgs():
        if arg == '-all':
            all = True

    if all:
        refresh_all()
    else:
        refresh(wikipedia.getSite())

        watchlist = get(wikipedia.getSite())
        wikipedia.output(u'%i pages in the watchlist.' % len(watchlist))
        for pageName in watchlist:
            wikipedia.output(pageName, toStdout = True)

if __name__ == "__main__":
    try:
        main()
    except:
        wikipedia.stopme()
        raise
    else:
        wikipedia.stopme()
