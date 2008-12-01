# -*- coding: utf-8  -*-

import family

# The official Mozilla Wiki.

class Family(family.Family):
    def __init__(self):
        family.Family.__init__(self)

        self.name = 'nif'

        self.langs = {
                'en': 'openccdb.org',
        }
        self.namespaces[4] = {
            '_default': [u'NIF', self.namespaces[4]['_default']],
        }
        self.namespaces[5] = {
            '_default': [u'NIF talk', self.namespaces[5]['_default']],
        }

        self.content_id = "mainContent"

    def version(self, code):
        return "1.12alpha"

    def scriptpath(self, code):
        return ''

    def path(self, code):
        return '/ontowiki/index.php'

    def apipath(self, code):
        raise NotImplementedError(
            "The mozilla family does not support api.php")
