self['dns']['aliases'] += self.static.domains.keys
self['dns']['aliases'].uniq!
