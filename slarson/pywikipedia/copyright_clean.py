# -*- coding: utf-8  -*-
"""
"""
__version__ = '$Id: copyright_clean.py 5846 2008-08-24 20:53:27Z siebrand $'

#
# (C) Francesco Cosoleto, 2006
#
# Distributed under the terms of the MIT license.
#

import httplib, socket, simplejson, re, time
import config, wikipedia, catlib, pagegenerators, query

from urllib import urlencode
from copyright import mysplit, put, reports_cat, join_family_data

import sys

summary_msg = {
    'ar': u'إزالة',
    'en': u'Removing',
    'it': u'Rimozione',
}

headC = re.compile("(?m)^=== (?:<strike>)?(?:<s>)?(?:<del>)?\[\[(?::)?(.*?)\]\]")
separatorC = re.compile('(?m)^== +')
next_headC = re.compile("(?m)^=+.*?=+")

#
# {{botbox|title|newid|oldid|author|...}}
rev_templateC = re.compile("(?m)^(?:{{/t\|.*?}}\n?)?{{(?:/box|botbox)\|.*?\|(.*?)\|")

def query_api(data):
    predata = [
          ('format', 'json'),
          ('action', 'query'),
          ('prop', 'revisions'),
          data]
    data = urlencode(predata)
    host = wikipedia.getSite().hostname()
    address = wikipedia.getSite().api_address()
    conn = httplib.HTTPConnection(host)
    conn.request("GET", address + data)
    response = conn.getresponse()
    data = response.read()
    conn.close()
    return data

def query_old_api(data):

    predata = [
          ('format', 'json'),
          ('what', 'revisions'),
          ('rvlimit', '1'),
          data]

    data = urlencode(predata)
    host = wikipedia.getSite().hostname()
    address = wikipedia.getSite().query_address()
    conn = httplib.HTTPConnection(host)
    conn.request("GET", address + data)
    response = conn.getresponse()
    data = response.read()
    conn.close()

    return data

def old_page_exist(title):
    for pageobjs in query_results_titles:
        for key in pageobjs['pages']:
            if pageobjs['pages'][key]['title'] == title:
                if int(key) >= 0:
                    return True
    wikipedia.output('* ' + title)
    return False

def old_revid_exist(revid):
    for pageobjs in query_results_revids:
        for id in pageobjs['pages']:
            for rv in range(len(pageobjs['pages'][id]['revisions'])):
                if pageobjs['pages'][id]['revisions'][rv]['revid'] == int(revid):
                    # print rv
                    return True
    wikipedia.output('* ' + revid)
    return False

def page_exist(title):
    for pageobjs in query_results_titles:
        for key in pageobjs['query']['pages']:
            if pageobjs['query']['pages'][key]['title'] == title:
                if pageobjs['query']['pages'][key].has_key('missing'):
                    wikipedia.output('* ' + title)
                    return False
    return True

def revid_exist(revid):
    for pageobjs in query_results_revids:
        if pageobjs['query'].has_key('badrevids'):
            for id in pageobjs['query']['badrevids']:
                if id == int(revid):
                    # print rv
                    wikipedia.output('* ' + revid)
                    return False
    return True

cat = catlib.Category(wikipedia.getSite(), 'Category:%s' % wikipedia.translate(wikipedia.getSite(), reports_cat))
gen = pagegenerators.CategorizedPageGenerator(cat, recurse = True)

for page in gen:
    data = page.get()
    wikipedia.output(page.aslink())
    output = ''

    #
    # Preserve text before of the sections
    #

    m = re.search("(?m)^==\s*[^=]*?\s*==", data)
    if m:
        output = data[:m.end() + 1]
    else:
        m = re.search("(?m)^===\s*[^=]*?", data)
        if not m:
            continue
        output = data[:m.start()]

    titles = headC.findall(data)
    titles = [re.sub("#.*", "", item) for item in titles]
    revids = rev_templateC.findall(data)

    query_results_titles = list()
    query_results_revids = list()

    # No more of 50 titles at a time using API
    for s in mysplit(query.ListToParam(titles), 50, "|"):
        query_results_titles.append(simplejson.loads(query_api(('titles', s))))
    for s in mysplit(query.ListToParam(revids), 50, "|"):
        query_results_revids.append(simplejson.loads(query_api(('revids', s))))

    comment_entry = list()
    add_separator = False
    index = 0

    while True:
        head = headC.search(data, index)
        if not head:
            break
        index = head.end()
        title = re.sub("#.*", "", head.group(1))
        next_head = next_headC.search(data, index)
        if next_head:
            if separatorC.search(data[next_head.start():next_head.end()]):
                add_separator = True
            stop = next_head.start()
        else:
            stop = len(data)

        exist = True
        if page_exist(title):
            # check {{botbox}}
            revid = re.search("{{(?:/box|botbox)\|.*?\|(.*?)\|", data[head.end():stop])
            if revid:
                if not revid_exist(revid.group(1)):
                    exist = False
        else:
           exist = False

        if exist:
            ctitle = re.sub(u'(?i)=== \[\[%s:' % join_family_data('Image', 6), ur'=== [[:\1:', title)
            ctitle = re.sub(u'(?i)=== \[\[%s:' % join_family_data('Category', 14), ur'=== [[:\1:', ctitle)
            output += "=== [[" + ctitle + "]]" + data[head.end():stop]
        else:
            comment_entry.append("[[%s]]" % title)

        if add_separator:
            output += data[next_head.start():next_head.end()] + '\n'
            add_separator = False

    add_comment = u'%s: %s' % (wikipedia.translate(wikipedia.getSite(), summary_msg),", ".join(comment_entry))

    # remove useless newlines
    output = re.sub("(?m)^\n", "", output)

    if comment_entry:
        wikipedia.output(add_comment)
        if wikipedia.verbose:
            wikipedia.showDiff(page.get(), output)

        if len(sys.argv)!=1:
            choice = wikipedia.inputChoice(u'Do you want to clean the page?',  ['Yes', 'No'], ['y', 'n'], 'n')
            if choice == 'n':
               continue
        try:
            put(page, output, add_comment)
        except wikipedia.PageNotSaved:
            raise

wikipedia.stopme()
