__version__ = '$Id: diskcache.py 5846 2008-08-24 20:53:27Z siebrand $'

import random
import config
import sys
import os

# http://mail.python.org/pipermail/python-list/2006-March/375280.html
try:
     os.SEEK_SET
except AttributeError:
     os.SEEK_SET, os.SEEK_CUR, os.SEEK_END = range(3)

## Dictionary like disk caching module
## (c) Copyright 2008 - Bryan Tong Minh / The Pywikipediabot team
## Licensed under the terms of the MIT license

class CachedReadOnlyDictI(object):
    """A cached readonly dict with case insensitive keys."""
    def __init__(self, data, prefix = "", max_size = 10, cache_base = 'cache'):
        self.max_size = max_size
        while True:
            self.cache_path = config.datafilepath(cache_base, prefix + ''.join(
                [random.choice('abcdefghijklmnopqrstuvwxyz')
                    for i in xrange(16)]))
            if not os.path.exists(self.cache_path): break
        self.cache_file = open(self.cache_path, 'wb+')

        lookup = [-1] * 36
        data.sort(key = lambda i: i[0])
        for key, value in data:
            if type(key) is unicode:
                key = key.encode('utf-8')
            elif type(key) != str:
                key = str(key)
            key = key.lower()
            index = key[0]
            if not ((index >= 'a' and index <= 'z') or (index >= '0' and index <= '9')) or '\t' in key:
                raise RuntimeError('Only alphabetic keys are supported', key)

            if index < 'a':
                index = ord(index) - 48 + 26 # Numeric
            else:
                index = ord(index) - 97
            if lookup[index] == -1:
                lookup[index] = self.cache_file.tell()

            if type(value) is unicode:
                value = value.encode('utf-8')
            elif type(value) != str:
                value = str(value)

            if len(key) > 0xFF:
                raise RuntimeError('Key length must be smaller than %i' % 0xFF)
            if len(value) > 0xFFFFFF:
                raise RuntimeError('Value length must be smaller than %i' % 0xFFFFFF)

            self.cache_file.write('%02x%s%06x%s' % (len(key), key, len(value), value))

        self.lookup = lookup
        self.cache_file.seek(0)
        self.cache = []

    def delete(self):
        self.cache_file.close()
        import os
        os.unlink(self.cache_path)
        os = None

    def __getitem__(self, key):
        key = key.lower()
        if type(key) is unicode:
            key = key.encode('utf-8')

        try:
            index = key[0]
        except IndexError:
            raise KeyError(key)
        if not ((index >= 'a' and index <= 'z') or (index >= '0' and index <= '9')):
            raise KeyError(key)

        if index < 'a':
            if index < '0' or index > '9':
                raise KeyError(key)
            i = ord(index) - 48 + 26 # Numeric
        else:
            if index > 'z':
                raise KeyError(key)
            i = ord(index) - 97

        for k, v in self.cache:
            if k == key:
                self.cache.remove((k, v))
                self.cache.append((k, v))

        self.cache_file.seek(self.lookup[i])
        while True:
            length = int(self.read(2, key), 16)
            k = self.read(length, key)
            if k == key:
                length = int(self.read(6, key), 16)
                value = self.read(length, key).decode('utf-8')
                if len(self.cache) > self.max_size:
                    del self.cache[0]
                self.cache.append((key, value))
                return value

            elif k[0] != index:
                raise KeyError(key)

            length = int(self.read(6, key), 16)
            self.cache_file.seek(length, os.SEEK_CUR)


    def read(self, length, key = ''):
        s = self.cache_file.read(length)
        if not s: raise KeyError(key)
        return s
