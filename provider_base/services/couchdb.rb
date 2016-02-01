#
# custom logic for couchdb json resolution
# ============================================
#
# bigcouch is no longer maintained, so now the default behavior is
# to always use plain couchdb, unless there are more than one couchdb
# node or if "couch.mode" property is set to "multimaster".
#

couchdb_nodes = nodes_like_me['services' => 'couchdb']

if couchdb_nodes.size > 1 || self['couch']['mode'] == "multimaster"
  apply_partial 'services/_couchdb_multimaster.json'
else
  apply_partial 'services/_couchdb_plain.json'
end
