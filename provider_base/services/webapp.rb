self['dns']['aliases'] += [domain.full, webapp.domain, api.domain, nickserver.domain]
self['dns']['aliases'].uniq!
