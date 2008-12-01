# -*- coding: utf-8  -*-

import family

# The official Mozilla Wiki.

class Family(family.Family):
    def __init__(self):
        family.Family.__init__(self)

        self.name = 'nif'

        self.langs = {
                'en': 'neurolex.org',
        }
        self.namespaces[4] = {
            '_default': [u'NIF', self.namespaces[4]['_default']],
        }
        self.namespaces[5] = {
            '_default': [u'NIF talk', self.namespaces[5]['_default']],
        }

        self.content_id = "mainContent"

    def version(self, code):
        return "1.13.2"

