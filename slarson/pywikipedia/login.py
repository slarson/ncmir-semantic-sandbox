#!/usr/bin/python
# -*- coding: utf-8  -*-
"""
Script to log the robot in to a wiki account.

Suggestion is to make a special account to use for robot use only. Make
sure this robot account is well known on your home wikipedia before using.

Parameters:

   -all         Try to log in on all sites where a username is defined in
                user-config.py.

   -pass        Useful in combination with -all when you have accounts for
                several sites and use the same password for all of them.
                Asks you for the password, then logs in on all given sites.

   -pass:XXXX   Uses XXXX as password. Be careful if you use this
                parameter because your password will be shown on your
                screen, and will probably be saved in your command line
                history. This is NOT RECOMMENDED for use on computers
                where others have either physical or remote access.
                Use -pass instead.

   -sysop       Log in with your sysop account.

   -force       Ignores if the user is already logged in, and tries to log in.

If not given as parameter, the script will ask for your username and password
(password entry will be hidden), log in to your home wiki using this
combination, and store the resulting cookies (containing your password hash,
so keep it secured!) in a file in the login-data subdirectory.

All scripts in this library will be looking for this cookie file and will use the
login information if it is present.

To log out, throw away the XX-login.data file that is created in the login-data
subdirectory.
"""
#
# (C) Rob W.W. Hooft, 2003
#
# Distributed under the terms of the MIT license.
#
__version__='$Id: login.py 5992 2008-10-18 15:26:39Z nicdumz $'

import re
import urllib2
import wikipedia, config

# On some wikis you are only allowed to run a bot if there is a link to
# the bot's user page in a specific list.
botList = {
    'wikipedia': {
        'en': u'Wikipedia:Registered bots',
        # Disabled because they are now using a template system which
        # we can't check with our current code.
        #'simple': u'Wikipedia:Bots',
    },
    'gentoo': {
        'en': u'Help:Bots',
    }
}


class LoginManager:
    def __init__(self, password = None, sysop = False, site = None):
        self.site = site or wikipedia.getSite()
        if sysop:
            try:
                self.username = config.sysopnames[self.site.family.name][self.site.lang]
            except:
                raise wikipedia.NoUsername(u'ERROR: Sysop username for %s:%s is undefined.\nIf you have a sysop account for that site, please add such a line to user-config.py:\n\nsysopnames[\'%s\'][\'%s\'] = \'myUsername\'' % (self.site.family.name, self.site.lang, self.site.family.name, self.site.lang))
        else:
            try:
                self.username = config.usernames[self.site.family.name][self.site.lang]
            except:
                raise wikipedia.NoUsername(u'ERROR: Username for %s:%s is undefined.\nIf you have an account for that site, please add such a line to user-config.py:\n\nusernames[\'%s\'][\'%s\'] = \'myUsername\'' % (self.site.family.name, self.site.lang, self.site.family.name, self.site.lang))
        self.password = password
        if getattr(config, 'password_file', ''):
            self.readPassword()

    def botAllowed(self):
        """
        Checks whether the bot is listed on a specific page to comply with
        the policy on the respective wiki.
        """
        if botList.has_key(self.site.family.name) and botList[self.site.family.name].has_key(self.site.language()):
            botListPageTitle = botList[self.site.family.name][self.site.language()]
            botListPage = wikipedia.Page(self.site, botListPageTitle)
            for linkedPage in botListPage.linkedPages():
                if linkedPage.titleWithoutNamespace() == self.username:
                    return True
            return False
        else:
            # No bot policies on other
            return True

    def getCookie(self, remember=True, captcha = None):
        """
        Login to the site.

        remember    Remember login (default: True)
        captchaId   A dictionary containing the captcha id and answer, if any

        Returns cookie data if succesful, None otherwise.
        """
        if config.use_api_login:
            predata = {
                'action': 'login',
                'lgname': self.username.encode(self.site.encoding()),
                'lgpassword': self.password,
                'lgdomain': self.site.family.ldapDomain,
            }
            address = self.site.api_address()
        else:
            predata = {
                "wpName": self.username.encode(self.site.encoding()),
                "wpPassword": self.password,
                "wpDomain": self.site.family.ldapDomain,     # VistaPrint fix
                "wpLoginattempt": "Aanmelden & Inschrijven", # dutch button label seems to work for all wikis
                "wpRemember": str(int(bool(remember))),
                "wpSkipCookieCheck": '1'
            }
            if captcha:
                predata["wpCaptchaId"] = captcha['id']
                predata["wpCaptchaWord"] = captcha['answer']
            login_address = self.site.login_address()
            address = login_address + '&action=submit'

        if self.site.hostname() in config.authenticate.keys():
            headers = {
                "Content-type": "application/x-www-form-urlencoded",
                "User-agent": wikipedia.useragent
            }
            data = self.site.urlEncode(predata)
            response = urllib2.urlopen(urllib2.Request(self.site.protocol() + '://' + self.site.hostname() + address, data, headers))
            data = response.read()
            wikipedia.cj.save(wikipedia.COOKIEFILE)
            return "Ok"
        else:
            response, data = self.site.postData(address, self.site.urlEncode(predata))
            Reat=re.compile(': (.*?);')
            L = []

            for eat in response.msg.getallmatchingheaders('set-cookie'):
                m = Reat.search(eat)
                if m:
                    L.append(m.group(1))

            got_token = got_user = False
            for Ldata in L:
                if 'Token=' in Ldata:
                    got_token = True
                if 'User=' in Ldata or 'UserName=' in Ldata:
                    got_user = True

            if got_token and got_user:
                return "\n".join(L)
            elif not captcha:
                solve = self.site.solveCaptcha(data)
                if solve:
                    return self.getCookie(remember = remember, captcha = solve)
            return None

    def storecookiedata(self, data):
        """
        Stores cookie data.

        The argument data is the raw data, as returned by getCookie().

        Returns nothing."""
        filename = wikipedia.config.datafilepath('login-data',
                       '%s-%s-%s-login.data'
                       % (self.site.family.name, self.site.lang, self.username))
        f = open(filename, 'w')
        f.write(data)
        f.close()

    def readPassword(self):
        """
            Reads passwords from a file. DO NOT FORGET TO REMOVE READ
            ACCESS FOR OTHER USERS!!! Use chmod 600 password-file.
            All lines below should be valid Python tuples in the form
            (code, family, username, password) or (username, password)
            to set a default password for an username. Default usernames
            should occur above specific usernames.

            Example:

            ("my_username", "my_default_password")
            ("my_sysop_user", "my_sysop_password")
            ("en", "wikipedia", "my_en_user", "my_en_pass")
        """
        file = open(config.password_file)
        for line in file:
            if not line.strip(): continue
            entry = eval(line)
            if len(entry) == 2:
                if entry[0] == self.username: self.password = entry[1]
            elif len(entry) == 4:
                if entry[0] == self.site.lang and \
                  entry[1] == self.site.family.name and \
                  entry[2] == self.username:
                    self.password = entry[3]
        file.close()

    def login(self, retry = False):
        if not self.password:
            # As we don't want the password to appear on the screen, we set
            # password = True
            self.password = "nifbot"#wikipedia.input(u'Password for user %s on %s:' % (self.username, self.site), password = True)

        self.password = "nifbot"#self.password.encode(self.site.encoding())

        wikipedia.output(u"Logging in to %s as %s" % (self.site, self.username))
        cookiedata = self.getCookie()
        if cookiedata:
            self.storecookiedata(cookiedata)
            wikipedia.output(u"Should be logged in now")
            # Show a warning according to the local bot policy
            if not self.botAllowed():
                wikipedia.output(u'*** Your username is not listed on [[%s]].\n*** Please make sure you are allowed to use the robot before actually using it!' % botList[self.site.family.name][self.site.lang])
            return True
        else:
            wikipedia.output(u"Login failed. Wrong password or CAPTCHA answer?")
            if retry:
                self.password = None
                return self.login(retry = True)
            else:
                return False

    def showCaptchaWindow(self, url):
        pass

def main():
    username = password = None
    sysop = False
    logall = False
    forceLogin = False
    for arg in wikipedia.handleArgs():
        if arg.startswith("-pass"):
            if len(arg) == 5:
                password = wikipedia.input(u'Password for all accounts:', password = True)
            else:
                password = arg[6:]
        elif arg == "-sysop":
            sysop = True
        elif arg == "-all":
            logall = True
        elif arg == "-force":
            forceLogin = True
        else:
            wikipedia.showHelp('login')
            return
    if logall:
        if sysop:
            namedict = config.sysopnames
        else:
            namedict = config.usernames
        for familyName in namedict.iterkeys():
            for lang in namedict[familyName].iterkeys():
                try:
                    site = wikipedia.getSite(code=lang, fam=familyName)
                    if not forceLogin and site.loggedInAs(sysop = sysop) != None:
                        wikipedia.output(u'Already logged in on %s' % site)
                    else:
                        loginMan = LoginManager(password, sysop = sysop, site = site)
                        loginMan.login()
                except wikipedia.NoSuchSite:
                    wikipedia.output(lang+ u'.' + familyName + u' is not a valid site, please remove it from your config')

    else:
        loginMan = LoginManager(password, sysop = sysop)
        loginMan.login()

if __name__ == "__main__":
    try:
        main()
    finally:
        wikipedia.stopme()
