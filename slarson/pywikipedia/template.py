# -*- coding: utf-8 -*-
"""
Very simple script to replace a template with another one,
and to convert the old MediaWiki boilerplate format to the new template format.

Syntax: python template.py [-remove] [xml[:filename]] oldTemplate [newTemplate]

Specify the template on the command line. The program will
pick up the template page, and look for all pages using it. It will
then automatically loop over them, and replace the template.

Command line options:

-remove      Remove every occurence of the template from every article

-subst       Resolves the template by putting its text directly into the article.
             This is done by changing {{...}} or {{msg:...}} into {{subst:...}}

-xml         retrieve information from a local dump (http://download.wikimedia.org).
             if this argument isn\'t given, info will be loaded from the maintenance
             page of the live wiki.
             argument can also be given as "-xml:filename.xml".

-namespace:  Only process templates in the given namespace number (may be used
             multiple times).

-summary:    Lets you pick a custom edit summary.  Use quotes if edit summary contains
             spaces.

-always      Don't bother asking to confirm any of the changes, Just Do It.

-page:       Only edit a specific page.  You can use this argument multiple times to work
             on multiple pages.  If the page title has spaces in it, enclose the entire
             page name in quotes.

-category:   Appends the given category to every page that is edited.  This is useful when
             a category is being broken out from a template parameter or when templates are
             being upmerged but more information must be preserved.

other:       First argument is the old template name, second one is the new
             name.

             If you want to address a template which has spaces, put quotation
             marks around it, or use underscores.

Examples:

If you have a template called [[Template:Cities in Washington]] and want to
change it to [[Template:Cities in Washington state]], start

    python template.py "Cities in Washington" "Cities in Washington state"

Move the page [[Template:Cities in Washington]] manually afterwards.


If you have a template called [[Template:test]] and want to substitute it only on pages
in the User: and User talk: namespaces, do:

    python template.py test -namespace:2 -namespace:3

Note that, on the English Wikipedia, User: is namespace 2 and User talk: is namespace 3.
This may differ on other projects so make sure to find out the appropriate namespace numbers.


This next example substitutes the template lived with a supplied edit summary.  It only
performs substitutions in main article namespace and doesn't prompt to start replacing.
Note that -putthrottle: is a global pywikipedia parameter.

    python template.py -putthrottle:30 -namespace:0 lived -always
        -summary:"ROBOT: Substituting {{lived}}, see [[WP:SUBST]]."


This next example removes the templates {{cfr}}, {{cfru}}, and {{cfr-speedy}} from five
category pages as given:

    python template.py cfr cfru cfr-speedy -remove -always
        -page:"Category:Mountain monuments and memorials" -page:"Category:Indian family names"
        -page:"Category:Tennis tournaments in Belgium" -page:"Category:Tennis tournaments in Germany"
        -page:"Category:Episcopal cathedrals in the United States"
        -summary:"Removing Cfd templates from category pages that survived."


This next example substitutes templates test1, test2, and space test on all pages:

    python template.py test1 test2 "space test" -subst -always

"""
#
# (C) Daniel Herding, 2004
# (C) Rob W.W. Hooft, 2003
#
# Distributed under the terms of the MIT license.
#
__version__='$Id: template.py 5846 2008-08-24 20:53:27Z siebrand $'
#
import wikipedia, config
import replace, pagegenerators
import re, sys, string, catlib

class XmlDumpTemplatePageGenerator:
    """
    Generator which will yield Pages to pages that might contain the chosen
    template. These pages will be retrieved from a local XML dump file
    (cur table).
    """
    def __init__(self, templates, xmlfilename):
        """
        Arguments:
            * templateNames - A list of Page object representing the searched
                              templates
            * xmlfilename   - The dump's path, either absolute or relative
        """

        self.templates = templates
        self.xmlfilename = xmlfilename

    def __iter__(self):
        """
        Yield page objects until the entire XML dump has been read.
        """
        import xmlreader
        mysite = wikipedia.getSite()
        dump = xmlreader.XmlDump(self.xmlfilename)
        # regular expression to find the original template.
        # {{vfd}} does the same thing as {{Vfd}}, so both will be found.
        # The old syntax, {{msg:vfd}}, will also be found.
        # TODO: check site.nocapitalize()
        templatePatterns = []
        for template in self.templates:
            templatePattern = template.titleWithoutNamespace()
            if not wikipedia.getSite().nocapitalize:
                templatePattern = '[' + templatePattern[0].upper() + templatePattern[0].lower() + ']' + templatePattern[1:]
            templatePattern = re.sub(' ', '[_ ]', templatePattern)
            templatePatterns.append(templatePattern)
        templateRegex = re.compile(r'\{\{ *([mM][sS][gG]:)?(?:%s) *(?P<parameters>\|[^}]+|) *}}' % '|'.join(templatePatterns))

        for entry in dump.parse():
            if templateRegex.search(entry.text):
                page = wikipedia.Page(mysite, entry.title)
                yield page

class TemplateRobot:
    """
    This robot will load all pages yielded by a page generator and replace or
    remove all occurences of the old template, or substitute them with the
    template's text.
    """
    # Summary messages for replacing templates
    msg_change={
	    'ar':u'روبوت: تغيير القالب: %s',
        'da':u'Bot: Erstatter skabelon: %s',
        'de':u'Bot: Ändere Vorlage: %s',
        'en':u'Robot: Changing template: %s',
        'es':u'Robot: Cambiada la plantilla: %s',
        'fr':u'Robot: Change modèle: %s',
        'he':u'בוט: משנה תבנית: %s',
        'hu':u'Robot: Sablon csere: %s',
        'ia':u'Robot: Modification del template: %s',
        'kk':u'Бот: Мына үлгі өзгертілді: %s',
        'lt':u'robotas: Keičiamas šablonas: %s',
        'nds':u'Bot: Vörlaag utwesselt: %s',
        'ja':u'ロボットによるテンプレートの張り替え : %s',
        'nl':u'Bot: Vervangen sjabloon: %s',
        'no':u'bot: Endrer mal: %s',
        'pl':u'Robot zmienia szablon: %s',
        'pt':u'Bot: Alterando predefinição: %s',
        'ru':u'Робот: замена шаблона: %s',
        'sr':u'Бот: Измена шаблона: %s',
        'zh':u'機器人: 更改模板 %s',
    }

    #Needs more translations!
    msgs_change={
	    'ar':u'روبوت: تغيير القوالب: %s',
        'da':u'Bot: Erstatter skabeloner: %s',
        'de':u'Bot: Ändere Vorlagen: %s',
        'en':u'Robot: Changing templates: %s',
        'es':u'Robot: Cambiando las plantillas: %s',
        'fr':u'Bot: Modifie modèles %s',
        'he':u'בוט: משנה תבניות: %s',
        'kk':u'Бот: Мына үлгілер өзгертілді: %s',
        'lt':u'robotas: Keičiami šablonai: %s',
        'nds':u'Bot: Vörlagen utwesselt: %s',
        'ja':u'ロボットによるテンプレートの張り替え : %s',
        'nl':u'Bot: Vervangen sjablonen: %s',
        'no':u'bot: Endrer maler: %s',
        'pl':u'Robot zmienia szablony: %s',
        'pt':u'Bot: Alterando predefinição: %s',
        'ru':u'Робот: замена шаблонов: %s',
        'zh':u'機器人: 更改模板 %s',
    }

    # Summary messages for removing templates
    msg_remove={
	    'ar':u'روبوت: إزالة القالب: %s',
        'da':u'Bot: Fjerner skabelon: %s',
        'de':u'Bot: Entferne Vorlage: %s',
        'en':u'Robot: Removing template: %s',
        'es':u'Robot: Retirando la plantilla: %s',
        'fr':u'Robot: Enlève le modèle: %s',
        'he':u'בוט: מסיר תבנית: %s',
        'hu':u'Robot: Sablon eltávolítása: %s',
        'kk':u'Бот: Мына үлгі аластатылды: %s',
        'ia':u'Robot: Elimination del template: %s',
        'lt':u'robotas: Šalinamas šablonas: %s',
        'nds':u'Bot: Vörlaag rut: %s',
        'ja':u'ロボットによるテンプレートの除去 : %s',
        'nl':u'Bot: Verwijderen sjabloon: %s',
        'no':u'bot: Fjerner mal: %s',
        'pl':u'Robot usuwa szablon: %s',
        'pt':u'Bot: Removendo predefinição: %s',
        'ru':u'Робот: удаление шаблона: %s',
        'sr':u'Бот: Уклањање шаблона: %s',
        'zh':u'機器人: 移除模板 %s',
    }

    #Needs more translations!
    msgs_remove={
	    'ar':u'روبوت: إزالة القوالب: %s',
        'da':u'Bot: Fjerner skabeloner: %s',
        'de':u'Bot: Entferne Vorlagen: %s',
        'en':u'Robot: Removing templates: %s',
        'es':u'Robot: Retirando las plantillas: %s',
        'he':u'בוט: מסיר תבניות: %s',
        'fr':u'Bot: Enlève modèles : %s',
        'kk':u'Бот: Мына үлгілер аластатылды: %s',
        'lt':u'robotas: Šalinami šablonai: %s',
        'nds':u'Bot: Vörlagen rut: %s',
        'ja':u'ロボットによるテンプレートの除去 : %s',
        'nl':u'Bot: Verwijderen sjablonen: %s',
        'no':u'bot: Fjerner maler: %s',
        'pl':u'Robot usuwa szablony: %s',
        'ru':u'Робот: удаление шаблонов: %s',
        'pt':u'Bot: Removendo predefinição: %s',
        'zh':u'機器人: 移除模板 %s',
    }

    # Summary messages for substituting templates
    #Needs more translations!
    msg_subst={
	    'ar':u'روبوت: نسخ القالب: %s',
        'da':u'Bot: Substituerer skabelon: %s',
        'de':u'Bot: Umgehe Vorlage: %s',
        'en':u'Robot: Substituting template: %s',
        'es':u'Robot: Sustituyendo la plantilla: %s',
        'fr':u'Bot: Remplace modèle : %s',
        'he':u'בוט: מכליל תבנית בקוד הדף: %s',
        'kk':u'Бот: Мына үлгі бәделдірленді: %s',
        'nds':u'Bot: Vörlaag in Text övernahmen: %s',
        'ja':u'ロボットによるテンプレートの置換 : %s',
        'nl':u'Bot: Substitueren sjabloon: %s',
        'no':u'bot: Erstatter mal: %s',
        'pl':u'Robot podmienia szablon: %s',
        'pt':u'Bot: Substituindo predefinição: %s',
        'ru':u'Робот: подстановка шаблона: %s',
        'zh':u'機器人: 更換模板 %s',
    }

    #Needs more translations!
    msgs_subst={
	    'ar':u'روبوت: نسخ القوالب: %s',
        'da':u'Bot: Substituerer skabeloner: %s',
        'de':u'Bot: Umgehe Vorlagen: %s',
        'en':u'Robot: Substituting templates: %s',
        'es':u'Robot: Sustituyendo las plantillas: %s',
        'fr':u'Bot: Remplace modèles : %s',
        'he':u'בוט: מכליל תבניות בקוד הדף: %s',
        'kk':u'Бот: Мына үлгілер бәделдірленді: %s',
        'nds':u'Bot: Vörlagen in Text övernahmen: %s',
        'ja':u'ロボットによるテンプレートの置換 : %s',
        'nl':u'Bot: Substitueren sjablonen: %s',
        'no':u'bot: Erstatter maler: %s',
        'pl':u'Robot podmienia szablony: %s',
        'pt':u'Bot: Substituindo predefinição: %s',
        'ru':u'Робот: подстановка шаблонов: %s',
        'zh':u'機器人: 更換模板 %s',
    }

    def __init__(self, generator, templates, subst = False, remove = False, editSummary = '',
                 acceptAll = False, addedCat = None):
        """
        Arguments:
            * generator    - A page generator.
            * replacements - A dictionary which maps old template names to
                             their replacements. If remove or subst is True,
                             it maps the names of the templates that should be
                             removed/resolved to None.
            * remove       - True if the template should be removed.
            * subst        - True if the template should be resolved.
        """
        self.generator = generator
        self.templates = templates
        self.subst = subst
        self.remove = remove
        self.editSummary = editSummary
        self.acceptAll = acceptAll
        self.addedCat = addedCat
        if self.addedCat:
            self.addedCat = catlib.Category(wikipedia.getSite(), 'Category:' + self.addedCat)

        # get edit summary message
        if self.editSummary:
            wikipedia.setAction(self.editSummary)
        else:
            oldTemplateNames = (', ').join(self.templates.keys())
            mysite = wikipedia.getSite()
            if self.remove:
                if len(self.templates) > 1:
                    wikipedia.setAction(wikipedia.translate(mysite, self.msgs_remove) % oldTemplateNames)
                else:
                    wikipedia.setAction(wikipedia.translate(mysite, self.msg_remove) % oldTemplateNames)
            elif self.subst:
                if len(self.templates) > 1:
                    wikipedia.setAction(wikipedia.translate(mysite, self.msgs_subst) % oldTemplateNames)
                else:
                    wikipedia.setAction(wikipedia.translate(mysite, self.msg_subst) % oldTemplateNames)
            else:
                if len(self.templates) > 1:
                    wikipedia.setAction(wikipedia.translate(mysite, self.msgs_change) % oldTemplateNames)
                else:
                    wikipedia.setAction(wikipedia.translate(mysite, self.msg_change) % oldTemplateNames)

    def run(self):
        """
        Starts the robot's action.
        """
        # regular expression to find the original template.
        # {{vfd}} does the same thing as {{Vfd}}, so both will be found.
        # The old syntax, {{msg:vfd}}, will also be found.
        # The group 'parameters' will either match the parameters, or an
        # empty string if there are none.

        replacements = []

        for old, new in self.templates.iteritems():
            if not wikipedia.getSite().nocapitalize:
                pattern = '[' + re.escape(old[0].upper()) + re.escape(old[0].lower()) + ']' + re.escape(old[1:])
            else:
                pattern = re.escape(old)
            pattern = re.sub(r'_|\\ ', r'[_ ]', pattern)
            templateRegex = re.compile(r'\{\{ *([Tt]emplate:|[mM][sS][gG]:)?' + pattern + r'(?P<parameters>\s*\|.+?|) *}}', re.DOTALL)

            if self.remove:
                replacements.append((templateRegex, ''))
            elif self.subst:
                replacements.append((templateRegex, '{{subst:' + old + '\g<parameters>}}'))
            else:
                replacements.append((templateRegex, '{{' + new + '\g<parameters>}}'))

        replaceBot = replace.ReplaceRobot(self.generator, replacements, exceptions = {}, acceptall = self.acceptAll, addedCat=self.addedCat)
        replaceBot.run()

def main():
    templateNames = []
    templates = {}
    subst = False
    remove = False
    namespaces = []
    editSummary = ''
    addedCat = ''
    acceptAll = False
    pageTitles = []
    # If xmlfilename is None, references will be loaded from the live wiki.
    xmlfilename = None
    # read command line parameters
    for arg in wikipedia.handleArgs():
        if arg == '-remove':
            remove = True
        elif arg == '-subst':
            subst = True
        elif arg.startswith('-xml'):
            if len(arg) == 4:
                xmlfilename = wikipedia.input(u'Please enter the XML dump\'s filename: ')
            else:
                xmlfilename = arg[5:]
        elif arg.startswith('-namespace:'):
            try:
                namespaces.append(int(arg[len('-namespace:'):]))
            except ValueError:
                namespaces.append(arg[len('-namespace:'):])
        elif arg.startswith('-category:'):
            addedCat = arg[len('-category:'):]
        elif arg.startswith('-summary:'):
            editSummary = arg[len('-summary:'):]
        elif arg.startswith('-always'):
            acceptAll = True
        elif arg.startswith('-page'):
            if len(arg) == len('-page'):
                pageTitles.append(wikipedia.input(u'Which page do you want to chage?'))
            else:
                pageTitles.append(arg[len('-page:'):])
        else:
            templateNames.append(arg)

    if subst or remove:
        for templateName in templateNames:
            templates[templateName] = None
    else:
        try:
            for i in range(0, len(templateNames), 2):
                templates[templateNames[i]] = templateNames[i + 1]
        except IndexError:
            wikipedia.output(u'Unless using -subst or -remove, you must give an even number of template names.')
            return

    oldTemplates = []
    ns = wikipedia.getSite().template_namespace()
    for templateName in templates.keys():
        oldTemplate = wikipedia.Page(wikipedia.getSite(), ns + ':' + templateName)
        oldTemplates.append(oldTemplate)

    if xmlfilename:
        gen = XmlDumpTemplatePageGenerator(oldTemplates, xmlfilename)
    elif pageTitles:
        pages = [wikipedia.Page(wikipedia.getSite(), pageTitle) for pageTitle in pageTitles]
        gen = iter(pages)
    else:
        gens = []
        gens = [pagegenerators.ReferringPageGenerator(t, onlyTemplateInclusion = True) for t in oldTemplates]
        gen = pagegenerators.CombinedPageGenerator(gens)
        gen = pagegenerators.DuplicateFilterPageGenerator(gen)

    if namespaces:
        gen =  pagegenerators.NamespaceFilterPageGenerator(gen, namespaces)

    preloadingGen = pagegenerators.PreloadingGenerator(gen)

    bot = TemplateRobot(preloadingGen, templates, subst, remove, editSummary, acceptAll, addedCat)
    bot.run()

if __name__ == "__main__":
    try:
        main()
    finally:
        wikipedia.stopme()
