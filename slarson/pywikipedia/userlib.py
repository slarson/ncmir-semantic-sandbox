﻿# -*- coding: utf-8  -*-
"""
Library to work with users, their pages and talk pages.
"""
__version__ = '$Id: userlib.py 4031 2007-08-12 20:25:38Z misza13 $'

import re, httplib
import wikipedia



class AutoblockUserError(wikipedia.Error):
    """
    The class AutoblockUserError is an exception that is raised whenever
    an action is requested on a virtual autoblock user that's not available
    for him (i.e. roughly everything except unblock).
    """

class BlockError(wikipedia.Error): pass

class AlreadyBlockedError(BlockError): pass

class UnblockError(wikipedia.Error): pass

class BlockIDError(UnblockError): pass

class AlreadyUnblockedError(UnblockError): pass

class User:
    """
    A class that represents a Wiki user.
    Has getters for the user's User: an User talk: (sub-)pages,
    as well as methods for blocking and unblocking.
    """

    #TODO list:
    #- browse contributions

    def __init__(self, site, name):
        """
        Initializer for a User object.

        Parameters:
        site - a wikipedia.Site object
        name - name of the user, without the trailing User:
        """

        self.site = site
        self.name = name

    def getUserPage(self, subpage=''):
        if self.name[0] == '#':
            #This user is probably being queried for purpose of lifting
            #an autoblock, so has no user pages per se.
            raise AutoblockUserError
        fullpagename = self.site.namespace(2) + ':' + self.name
        if subpage:
            fullpagename += '/' + subpage
        return wikipedia.Page(self.site, fullpagename)

    def getUserTalkPage(self, subpage=''):
        if self.name[0] == '#':
            #This user is probably being queried for purpose of lifting
            #an autoblock, so has no user talk pages per se.
            raise AutoblockUserError
        fullpagename = self.site.namespace(3) + ':' + self.name
        if subpage:
            fullpagename += '/' + subpage
        return wikipedia.Page(self.site,fullpagename)

    def editedPages(self, limit=500):
        """ Yields pages that the user has edited, with an upper bound of ``limit''.
        Pages returned are not guaranteed to be unique
        (straight Special:Contributions parsing, in chunks of 500 items)."""

        if self.name[0] == '#':
            #This user is probably being queried for purpose of lifting
            #an autoblock, so has no contribs.
            raise AutoblockUserError

        offset = 0
        step = min(limit,500)
        older_str = self.site.mediawiki_message('sp-contributions-older').replace('$1',str(step))
        address = self.site.contribs_address(self.name,limit=step)
        while offset < limit:
            wikipedia.output(u'Querying [[Special:Contributions/%s]]...' % self.name)
            data = self.site.getUrl(address)
            contribRX = re.compile('<li>.*?<a href=".*?" title="(?P<target>.*?)">(?P=target)</a>')
            for pg in contribRX.finditer(data):
                yield wikipedia.Page(self.site,pg.group('target'))
                offset += 1
                if offset == limit:
                    break
            nextRX = re.search('\(<a href="(?P<address>.*?)">' + older_str + '</a>\)',data)
            if nextRX:
                address = nextRX.group('address').replace('&amp;','&')
            else:
                break

    def block(self, expiry=None, reason=None, anonOnly=True, noSignup=False, enableAutoblock=False, emailBan=False):
        """
        Block the user.

        Parameters:
        expiry - expiry time of block, may be a period of time (incl. infinite)
                 or the block's expiry time
        reason - reason for block
        anonOnly - is the block affecting only anonymous users?
        noSignup - does the block disable account creation?
        enableAutoblock - is autoblock enabled on the block?
        emailBan - prevent user from sending e-mail?

        The default values for block options are set to as most unrestrictive
        """

        if self.name[0] == '#':
            #This user is probably being queried for purpose of lifting
            #an autoblock, so can't be blocked.
            raise AutoblockUserError

        if expiry == None:
            expiry = input(u'Please enter the expiry time for the block:')
        if reason == None:
            reason = input(u'Please enter a reason for the block:')

        token = self.site.getToken(self, sysop = True)

        wikipedia.output(u"Blocking [[User:%s]]..." % self.name)

        boolStr = ['0','1']
        predata = {
            'wpBlockAddress': self.name,
            'wpBlockOther': expiry,
            'wpBlockReasonList': reason,
            'wpAnonOnly': boolStr[anonOnly],
            'wpCreateAccount': boolStr[noSignup],
            'wpEnableAutoblock': boolStr[enableAutoblock],
            'wpEmailBan': boolStr[emailBan],
            'wpBlock': 'Block this user',
            'wpEditToken': token
        }

        address = self.site.block_address()
        response, data = self.site.postForm(address, predata, sysop = True)

        if data:
            # TODO: i18n
            if u'is already blocked' in data:
                raise AlreadyBlockedError
            raise BlockError
        return True

    def unblock(self, reason=None):
        """
        Unblock the user.

        Parameter:
        reason - reason for block
        """

        if self.name[0] == '#':
            blockID = self.name[1:]
        else:
            blockID = self._getBlockID()

        self._unblock(blockID,reason)

    def _getBlockID(self):
        wikipedia.output(u"Getting block id for [[User:%s]]..." % self.name)

        token = self.site.getToken(self, sysop = True)
        address = self.site.blocksearch_address(self.name)
        data = self.site.getUrl(address)
        bIDre = re.search(r'action=unblock&amp;id=(\d+)', data)
        if not bIDre:
            print data
            raise BlockIDError

        return bIDre.group(1)

    def _unblock(self, blockID, reason):
        wikipedia.output(u"Unblocking [[User:%s]]..." % self.name)

        token = self.site.getToken(self, sysop = True)

        predata = {
            'id': blockID,
            'wpUnblockReason': reason,
            'wpBlock': 'Unblock this address',
            'wpEditToken': token,
        }
        address = self.site.unblock_address()

        response, data = self.site.postForm(address, predata, sysop = True)
        if response.status != 302:
            # TODO: i18n
            if re.search('Block ID \d+ not found', data):
                raise AlreadyUnblockedError
            raise UnblockError, data
        return True


if __name__ == '__main__':
    """
    Simple testing code for the [[User:Example]] on the English Wikipedia.
    """
    try:
        Site = wikipedia.getSite()
        exampleUser = User(Site, 'Example')
        print exampleUser.getUserPage().get()
        print exampleUser.getUserPage('Lipsum').get()
        print exampleUser.getUserTalkPage().get()
    finally:
        wikipedia.stopme()
