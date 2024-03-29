# -*- coding: utf-8 -*-
"""
This bot will make direct text replacements. It will retrieve information on
which pages might need changes either from an XML dump or a text file, or only
change a single page.

These command line parameters can be used to specify which pages to work on:

&params;

-xml              Retrieve information from a local XML dump (pages-articles
                  or pages-meta-current, see http://download.wikimedia.org).
                  Argument can also be given as "-xml:filename".

-page             Only edit a specific page.
                  Argument can also be given as "-page:pagetitle". You can
                  give this parameter multiple times to edit multiple pages.

Furthermore, the following command line parameters are supported:

-regex            Make replacements using regular expressions. If this argument
                  isn't given, the bot will make simple text replacements.

-nocase           Use case insensitive regular expressions.

-xmlstart         (Only works with -xml) Skip all articles in the XML dump
                  before the one specified (may also be given as
                  -xmlstart:Article).

-addcat:cat_name  Adds "cat_name" category to every altered page.

-excepttitle:XYZ  Skip pages with titles that contain XYZ. If the -regex
                  argument is given, XYZ will be regarded as a regular
                  expression.

-requiretitle:XYZ Only do pages with titles that contain XYZ. If the -regex
                  argument is given, XYZ will be regarded as a regular
                  expression.

-excepttext:XYZ   Skip pages which contain the text XYZ. If the -regex
                  argument is given, XYZ will be regarded as a regular
                  expression.

-exceptinside:XYZ Skip occurences of the to-be-replaced text which lie
                  within XYZ. If the -regex argument is given, XYZ will be
                  regarded as a regular expression.

-exceptinsidetag:XYZ Skip occurences of the to-be-replaced text which lie
                  within an XYZ tag.

-summary:XYZ      Set the summary message text for the edit to XYZ, bypassing
                  the predefined message texts with original and replacements
                  inserted.

-sleep:123        If you use -fix you can check multiple regex at the same time
                  in every page. This can lead to a great waste of CPU because
                  the bot will check every regex without waiting using all the
                  resources. This will slow it down between a regex and another
                  in order not to waste too much CPU.

-fix:XYZ          Perform one of the predefined replacements tasks, which are
                  given in the dictionary 'fixes' defined inside the file
                  fixes.py.
                  The -regex and -nocase argument and given replacements will
                  be ignored if you use -fix.
                  Currently available predefined fixes are:
&fixes-help;

-namespace:n      Number or name of namespace to process. The parameter can be
                  used multiple times. It works in combination with all other
                  parameters, except for the -start parameter. If you e.g.
                  want to iterate over all categories starting at M, use
                  -start:Category:M.

-always           Don't prompt you for each replacement

-recursive        Recurse replacement as long as possible. Be careful, this
                  might lead to an infinite loop.

-allowoverlap     When occurences of the pattern overlap, replace all of them.
                  Be careful, this might lead to an infinite loop.

other:            First argument is the old text, second argument is the new
                  text. If the -regex argument is given, the first argument
                  will be regarded as a regular expression, and the second
                  argument might contain expressions like \\1 or \g<name>.

Examples:

If you want to change templates from the old syntax, e.g. {{msg:Stub}}, to the
new syntax, e.g. {{Stub}}, download an XML dump file (pages-articles) from
http://download.wikimedia.org, then use this command:

    python replace.py -xml -regex "{{msg:(.*?)}}" "{{\\1}}"

If you have a dump called foobar.xml and want to fix typos in articles, e.g.
Errror -> Error, use this:

    python replace.py -xml:foobar.xml "Errror" "Error" -namespace:0

If you have a page called 'John Doe' and want to fix the format of ISBNs, use:

    python replace.py -page:John_Doe -fix:isbn

This command will change 'referer' to 'referrer', but not in pages which
talk about HTTP, where the typo has become part of the standard:

    python replace.py referer referrer -file:typos.txt -excepttext:HTTP
"""
#
# (C) Daniel Herding & the Pywikipediabot Team, 2004-2008
#
# Distributed under the terms of the MIT license.
#

from __future__ import generators
import sys, re, time
import wikipedia, pagegenerators, catlib, config
import editarticle
import webbrowser

# Imports predefined replacements tasks from fixes.py
import fixes

# This is required for the text that is shown when you run this script
# with the parameter -help.
docuReplacements = {
    '&params;':     pagegenerators.parameterHelp,
    '&fixes-help;': fixes.help,
}

__version__='$Id: replace.py 5846 2008-08-24 20:53:27Z siebrand $'

# Summary messages in different languages
# NOTE: Predefined replacement tasks might use their own dictionary, see 'fixes'
# below.`v
msg = {
       'ar':u'%s روبوت : استبدال تلقائي للنص',
       'cs':u'Robot automaticky nahradil text: %s',
       'de':u'Bot: Automatisierte Textersetzung %s',
       'el':u'Ρομπότ: Αυτόματη αντικατάσταση κειμένου %s',
       'en':u'Robot: Automated text replacement %s',
       'es':u'Robot: Reemplazo automático de texto %s',
       'fa':u'ربات: تغییر خودکار متن %s',
       'fr':u'Bot : Remplacement de texte automatisé %s',
       'he':u'בוט: החלפת טקסט אוטומטית %s',
       'hu':u'Robot: Automatikus szövegcsere %s',
       'ia':u'Robot: Reimplaciamento automatic de texto %s',
       'id':u'Bot: Penggantian teks otomatis %s',
       'is':u'Vélmenni: breyti texta %s',
       'it':u'Bot: Sostituzione automatica %s',
       'ja':u'ロボットによる: 文字置き換え %s',
       'ka':u'რობოტი: ტექსტის ავტომატური შეცვლა %s',
       'kk':u'Бот: Мәтінді өздікті алмастырды: %s',
       'ksh':u'Bot: hät outomatesch Täx jetuusch: %s',
       'lt':u'robotas: Automatinis teksto keitimas %s',
       'nds':u'Bot: Text automaatsch utwesselt: %s',
       'nds-nl':u'Bot: autematisch tekse vervungen %s',
       'nl':u'Bot: automatisch tekst vervangen %s',
       'nn':u'robot: automatisk teksterstatning: %s',
       'no':u'robot: automatisk teksterstatning: %s',
       'pl':u'Robot automatycznie zamienia tekst %s',
       'pt':u'Bot: Mudança automática %s',
       'ru':u'Робот: Автоматизированная замена текста',
       'sr':u'Бот: Аутоматска замена текста %s',
       'sv':u'Bot: Automatisk textersättning: %s',
       'zh': u'機器人:執行文字代換作業 %s',
       }


class XmlDumpReplacePageGenerator:
    """
    Iterator that will yield Pages that might contain text to replace.

    These pages will be retrieved from a local XML dump file.
    Arguments:
        * xmlFilename  - The dump's path, either absolute or relative
        * xmlStart     - Skip all articles in the dump before this one
        * replacements - A list of 2-tuples of original text (as a
                         compiled regular expression) and replacement
                         text (as a string).
        * exceptions   - A dictionary which defines when to ignore an
                         occurence. See docu of the ReplaceRobot
                         constructor below.

    """
    def __init__(self, xmlFilename, xmlStart, replacements, exceptions):
        self.xmlFilename = xmlFilename
        self.replacements = replacements
        self.exceptions = exceptions
        self.xmlStart = xmlStart
        self.skipping = bool(xmlStart)

        self.excsInside = []
        if self.exceptions.has_key('inside-tags'):
            self.excsInside += self.exceptions['inside-tags']
        if self.exceptions.has_key('inside'):
            self.excsInside += self.exceptions['inside']
        import xmlreader
        self.site = wikipedia.getSite()
        dump = xmlreader.XmlDump(self.xmlFilename)
        self.parser = dump.parse()

    def __iter__(self):
        try:
            for entry in self.parser:
                if self.skipping:
                    if entry.title != self.xmlStart:
                        continue
                    self.skipping = False
                if not self.isTitleExcepted(entry.title) \
                        and not self.isTextExcepted(entry.text):
                    new_text = entry.text
                    for old, new in self.replacements:
                        new_text = wikipedia.replaceExcept(new_text, old, new, self.excsInside, self.site)
                    if new_text != entry.text:
                        yield wikipedia.Page(self.site, entry.title)
        except KeyboardInterrupt:
            try:
                if not self.skipping:
                    wikipedia.output(
                        u'To resume, use "-xmlstart:%s" on the command line.'
                        % entry.title)
            except NameError:
                pass

    def isTitleExcepted(self, title):
        if self.exceptions.has_key('title'):
            for exc in self.exceptions['title']:
                if exc.search(title):
                    return True
        if self.exceptions.has_key('require-title'):
            for req in self.exceptions['require-title']:
                if not req.search(title): # if not all requirements are met:
                    return True

        return False

    def isTextExcepted(self, text):
        if self.exceptions.has_key('text-contains'):
            for exc in self.exceptions['text-contains']:
                if exc.search(text):
                    return True
        return False


class ReplaceRobot:
    """
    A bot that can do text replacements.
    """
    def __init__(self, generator, replacements, exceptions={},
                 acceptall=False, allowoverlap=False, recursive=False,
                 addedCat=None, sleep=None):
        """
        Arguments:
            * generator    - A generator that yields Page objects.
            * replacements - A list of 2-tuples of original text (as a
                             compiled regular expression) and replacement
                             text (as a string).
            * exceptions   - A dictionary which defines when not to change an
                             occurence. See below.
            * acceptall    - If True, the user won't be prompted before changes
                             are made.
            * allowoverlap - If True, when matches overlap, all of them are
                             replaced.
            * addedCat     - If set to a value, add this category to every page
                             touched.

        Structure of the exceptions dictionary:
        This dictionary can have these keys:

            title
                A list of regular expressions. All pages with titles that
                are matched by one of these regular expressions are skipped.
            text-contains
                A list of regular expressions. All pages with text that
                contains a part which is matched by one of these regular
                expressions are skipped.
            inside
                A list of regular expressions. All occurences are skipped which
                lie within a text region which is matched by one of these
                regular expressions.
            inside-tags
                A list of strings. These strings must be keys from the
                exceptionRegexes dictionary in wikipedia.replaceExcept().

        """
        self.generator = generator
        self.replacements = replacements
        self.exceptions = exceptions
        self.acceptall = acceptall
        self.allowoverlap = allowoverlap
        self.recursive = recursive
        if addedCat:
            site = wikipedia.getSite()
            cat_ns = site.category_namespaces()[0]
            self.addedCat = wikipedia.Page(site,
                                           cat_ns + ':' + addedCat)
        self.sleep = sleep

    def isTitleExcepted(self, title):
        """
        Iff one of the exceptions applies for the given title, returns True.
        """
        if self.exceptions.has_key('title'):
            for exc in self.exceptions['title']:
                if exc.search(title):
                    return True
        if self.exceptions.has_key('require-title'):
            for req in self.exceptions['require-title']:
                if not req.search(title):
                    return True
        return False

    def isTextExcepted(self, original_text):
        """
        Iff one of the exceptions applies for the given page contents,
        returns True.
        """
        if self.exceptions.has_key('text-contains'):
            for exc in self.exceptions['text-contains']:
                if exc.search(original_text):
                    return True
        return False

    def doReplacements(self, original_text):
        """
        Returns the text which is generated by applying all replacements to
        the given text.
        """
        new_text = original_text
        exceptions = []
        if self.exceptions.has_key('inside-tags'):
            exceptions += self.exceptions['inside-tags']
        if self.exceptions.has_key('inside'):
            exceptions += self.exceptions['inside']
        for old, new in self.replacements:
            if self.sleep != None:
                time.sleep(self.sleep)
            new_text = wikipedia.replaceExcept(new_text, old, new, exceptions,
                                               allowoverlap=self.allowoverlap)
        return new_text

    def run(self):
        """
        Starts the robot.
        """
        # Run the generator which will yield Pages which might need to be
        # changed.
        for page in self.generator:
            if self.isTitleExcepted(page.title()):
                wikipedia.output(
                    u'Skipping %s because the title is on the exceptions list.'
                    % page.aslink())
                continue
            try:
                # Load the page's text from the wiki
                original_text = page.get(get_redirect=True)
                if not page.canBeEdited():
                    wikipedia.output(u"You can't edit page %s"
                                     % page.aslink())
                    continue
            except wikipedia.NoPage:
                wikipedia.output(u'Page %s not found' % page.aslink())
                continue
            new_text = original_text
            while True:
                if self.isTextExcepted(new_text):
                    wikipedia.output(
    u'Skipping %s because it contains text that is on the exceptions list.'
                        % page.aslink())
                    break
                new_text = self.doReplacements(new_text)
                if new_text == original_text:
                    wikipedia.output('No changes were necessary in %s'
                                     % page.aslink())
                    break
                if self.recursive:
                    newest_text = self.doReplacements(new_text)
                    while (newest_text!=new_text):
                        new_text = newest_text
                        newest_text = self.doReplacements(new_text)
                if hasattr(self, "addedCat"):
                    cats = page.categories(nofollow_redirects=True)
                    if self.addedCat not in cats:
                        cats.append(self.addedCat)
                        new_text = wikipedia.replaceCategoryLinks(new_text,
                                                                  cats)
                # Show the title of the page we're working on.
                # Highlight the title in purple.
                wikipedia.output(u"\n\n>>> \03{lightpurple}%s\03{default} <<<"
                                 % page.title())
                wikipedia.showDiff(original_text, new_text)
                if self.acceptall:
                    break
                choice = wikipedia.inputChoice(
                            u'Do you want to accept these changes?',
                            ['Yes', 'No', 'Edit', 'open in Browser', 'All', "Quit"],
                            ['y', 'N', 'e', 'b', 'a', 'q'], 'N')
                if choice == 'e':
                    editor = editarticle.TextEditor()
                    as_edited = editor.edit(original_text)
                    # if user didn't press Cancel
                    if as_edited and as_edited != new_text:
                        new_text = as_edited
                    continue
                if choice == 'b':
                    webbrowser.open("http://%s%s" % (
                        page.site().hostname(),
                        page.site().nice_get_address(page.title())
                    ))
                    wikipedia.input("Press Enter when finished in browser.")
                    original_text = page.get(get_redirect=True, force=True)
                    new_text = original_text
                    continue
                if choice == 'q':
                    return
                if choice == 'a':
                    self.acceptall = True
                if choice == 'y':
                    page.put_async(new_text)
                # choice must be 'N'
                break
            if self.acceptall and new_text != original_text:
                try:
                    page.put(new_text)
                except wikipedia.EditConflict:
                    wikipedia.output(u'Skipping %s because of edit conflict'
                                     % (page.title(),))
                except wikipedia.SpamfilterError, e:
                    wikipedia.output(
                        u'Cannot change %s because of blacklist entry %s'
                        % (page.title(), e.url))
                except wikipedia.PageNotSaved, error:
                    wikipedia.output(u'Error putting page: %s'
                                     % (error.args,))
                except wikipedia.LockedPage:
                    wikipedia.output(u'Skipping %s (locked page)'
                                     % (page.title(),))

def prepareRegexForMySQL(pattern):
    pattern = pattern.replace('\s', '[:space:]')
    pattern = pattern.replace('\d', '[:digit:]')
    pattern = pattern.replace('\w', '[:alnum:]')

    pattern = pattern.replace("'", "\\" + "'")
    #pattern = pattern.replace('\\', '\\\\')
    #for char in ['[', ']', "'"]:
    #    pattern = pattern.replace(char, '\%s' % char)
    return pattern


def main():
    add_cat = None
    gen = None
    # summary message
    summary_commandline = None
    # Array which will collect commandline parameters.
    # First element is original text, second element is replacement text.
    commandline_replacements = []
    # A list of 2-tuples of original text and replacement text.
    replacements = []
    # Don't edit pages which contain certain texts.
    exceptions = {
        'title':         [],
        'text-contains': [],
        'inside':        [],
        'inside-tags':   [],
        'require-title': [], # using a seperate requirements dict needs some
    }                        # major refactoring of code.

    # Should the elements of 'replacements' and 'exceptions' be interpreted
    # as regular expressions?
    regex = False
    # Predefined fixes from dictionary 'fixes' (see above).
    fix = None
    # the dump's path, either absolute or relative, which will be used
    # if -xml flag is present
    xmlFilename = None
    useSql = False
    PageTitles = []
    # will become True when the user presses a ('yes to all') or uses the
    # -always flag.
    acceptall = False
    # Will become True if the user inputs the commandline parameter -nocase
    caseInsensitive = False
    # Which namespaces should be processed?
    # default to [] which means all namespaces will be processed
    namespaces = []
    # Do all hits when they overlap
    allowoverlap = False
    # Do not recurse replacement
    recursive = False
    # This factory is responsible for processing command line arguments
    # that are also used by other scripts and that determine on which pages
    # to work on.
    genFactory = pagegenerators.GeneratorFactory()
    # Load default summary message.
    # BUG WARNING: This is probably incompatible with the -lang parameter.
    wikipedia.setAction(wikipedia.translate(wikipedia.getSite(), msg))
    # Between a regex and another (using -fix) sleep some time (not to waste
    # too much CPU
    sleep = None

    # Read commandline parameters.
    for arg in wikipedia.handleArgs():
        if arg == '-regex':
            regex = True
        elif arg.startswith('-xmlstart'):
            if len(arg) == 9:
                xmlStart = wikipedia.input(
                    u'Please enter the dumped article to start with:')
            else:
                xmlStart = arg[10:]
        elif arg.startswith('-xml'):
            if len(arg) == 4:
                xmlFilename = wikipedia.input(
                    u'Please enter the XML dump\'s filename:')
            else:
                xmlFilename = arg[5:]
        elif arg =='-sql':
            useSql = True
        elif arg.startswith('-page'):
            if len(arg) == 5:
                PageTitles.append(wikipedia.input(
                                    u'Which page do you want to change?'))
            else:
                PageTitles.append(arg[6:])
        elif arg.startswith('-excepttitle:'):
            exceptions['title'].append(arg[13:])
        elif arg.startswith('-requiretitle:'):
            exceptions['require-title'].append(arg[14:])
        elif arg.startswith('-excepttext:'):
            exceptions['text-contains'].append(arg[12:])
        elif arg.startswith('-exceptinside:'):
            exceptions['inside'].append(arg[14:])
        elif arg.startswith('-exceptinsidetag:'):
            exceptions['inside-tags'].append(arg[17:])
        elif arg.startswith('-fix:'):
            fix = arg[5:]
        elif arg.startswith('-sleep:'):
            sleep = float(arg[7:])
        elif arg == '-always':
            acceptall = True
        elif arg == '-recursive':
            recursive = True
        elif arg == '-nocase':
            caseInsensitive = True
        elif arg.startswith('-addcat:'):
            add_cat = arg[8:]
        elif arg.startswith('-namespace:'):
            try:
                namespaces.append(int(arg[11:]))
            except ValueError:
                namespaces.append(arg[11:])
        elif arg.startswith('-summary:'):
            wikipedia.setAction(arg[9:])
            summary_commandline = True
        elif arg.startswith('-allowoverlap'):
            allowoverlap = True
        else:
            generator = genFactory.handleArg(arg)
            if generator:
                gen = generator
            else:
                commandline_replacements.append(arg)

    if (len(commandline_replacements) % 2):
        raise wikipedia.Error, 'require even number of replacements.'
    elif (len(commandline_replacements) == 2 and fix == None):
        replacements.append((commandline_replacements[0],
                             commandline_replacements[1]))
        if summary_commandline == None:
            wikipedia.setAction(wikipedia.translate(wikipedia.getSite(), msg )
                                % (' (-' + commandline_replacements[0] + ' +'
                                   + commandline_replacements[1] + ')'))
    elif (len(commandline_replacements) > 1):
        if (fix == None):
            for i in xrange (0, len(commandline_replacements), 2):
                replacements.append((commandline_replacements[i],
                                     commandline_replacements[i + 1]))
            if summary_commandline == None:
                pairs = [( commandline_replacements[i],
                           commandline_replacements[i + 1] )
                         for i in range(0, len(commandline_replacements), 2)]
                replacementsDescription = '(%s)' % ', '.join(
                    [('-' + pair[0] + ' +' + pair[1]) for pair in pairs])
                wikipedia.setAction(
                    wikipedia.translate(wikipedia.getSite(), msg )
                    % replacementsDescription)
        else:
           raise wikipedia.Error(
               'Specifying -fix with replacements is undefined')
    elif fix == None:
        old = wikipedia.input(u'Please enter the text that should be replaced:')
        new = wikipedia.input(u'Please enter the new text:')
        change = '(-' + old + ' +' + new
        replacements.append((old, new))
        while True:
            old = wikipedia.input(
u'Please enter another text that should be replaced, or press Enter to start:')
            if old == '':
                change = change + ')'
                break
            new = wikipedia.input(u'Please enter the new text:')
            change = change + ' & -' + old + ' +' + new
            replacements.append((old, new))
        if not summary_commandline == True:
            default_summary_message =  wikipedia.translate(wikipedia.getSite(), msg) % change
            wikipedia.output(u'The summary message will default to: %s'
                             % default_summary_message)
            summary_message = wikipedia.input(
u'Press Enter to use this default message, or enter a description of the\nchanges your bot will make:')
            if summary_message == '':
                summary_message = default_summary_message
            wikipedia.setAction(summary_message)

    else:
        # Perform one of the predefined actions.
        try:
            fix = fixes.fixes[fix]
        except KeyError:
            wikipedia.output(u'Available predefined fixes are: %s'
                             % fixes.fixes.keys())
            return
        if fix.has_key('regex'):
            regex = fix['regex']
        if fix.has_key('msg'):
            wikipedia.setAction(
                wikipedia.translate(wikipedia.getSite(), fix['msg']))
        if fix.has_key('exceptions'):
            exceptions = fix['exceptions']
        replacements = fix['replacements']

    # already compile all regular expressions here to save time later
    for i in range(len(replacements)):
        old, new = replacements[i]
        if not regex:
            old = re.escape(old)
        if caseInsensitive:
            oldR = re.compile(old, re.UNICODE | re.IGNORECASE)
        else:
            oldR = re.compile(old, re.UNICODE)
        replacements[i] = oldR, new

    for exceptionCategory in ['title', 'require-title', 'text-contains', 'inside']:
        if exceptions.has_key(exceptionCategory):
            patterns = exceptions[exceptionCategory]
            if not regex:
                patterns = [re.escape(pattern) for pattern in patterns]
            if caseInsensitive:
                patterns = [re.compile(pattern, re.UNICODE | re.IGNORECASE)
                            for pattern in patterns]
            else:
                patterns = [re.compile(pattern, re.UNICODE)
                            for pattern in patterns]
            exceptions[exceptionCategory] = patterns

    if xmlFilename:
        try:
            xmlStart
        except NameError:
            xmlStart = None
        gen = XmlDumpReplacePageGenerator(xmlFilename, xmlStart,
                                          replacements, exceptions)
    elif useSql:
        whereClause = 'WHERE (%s)' % ' OR '.join(
            ["old_text RLIKE '%s'" % prepareRegexForMySQL(old.pattern)
             for (old, new) in replacements])
        if exceptions:
            exceptClause = 'AND NOT (%s)' % ' OR '.join(
                ["old_text RLIKE '%s'" % prepareRegexForMySQL(exc.pattern)
                 for exc in exceptions])
        else:
            exceptClause = ''
        query = u"""
SELECT page_namespace, page_title
FROM page
JOIN text ON (page_id = old_id)
%s
%s
LIMIT 200""" % (whereClause, exceptClause)
        gen = pagegenerators.MySQLPageGenerator(query)

    elif PageTitles:
        pages = [wikipedia.Page(wikipedia.getSite(), PageTitle)
                 for PageTitle in PageTitles]
        gen = iter(pages)

    if not gen:
        # syntax error, show help text from the top of this file
        wikipedia.showHelp('replace')
        return
    if namespaces != []:
        gen = pagegenerators.NamespaceFilterPageGenerator(gen, namespaces)
    if xmlFilename:
        # XML parsing can be quite slow, so use smaller batches and
        # longer lookahead.
        preloadingGen = pagegenerators.PreloadingGenerator(gen,
                                            pageNumber=20, lookahead=100)
    else:
        preloadingGen = pagegenerators.PreloadingGenerator(gen, pageNumber=60)
    bot = ReplaceRobot(preloadingGen, replacements, exceptions, acceptall, allowoverlap, recursive, add_cat, sleep)
    bot.run()

if __name__ == "__main__":
    try:
        main()
    finally:
        wikipedia.stopme()
