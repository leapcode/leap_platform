if self['static'] && self['static']['domains']
  self['dns']['aliases'] += self['static']['domains'].keys
  self['dns']['aliases'].uniq!
end