#
# custom logic for couchdb json resolution
# ============================================
#
# bigcouch is no longer maintained, so now the default behavior is
# to always use plain couchdb, unless there are more than one couchdb
# node or if "couch.mode" property is set to "multimaster".
#
# in the past, it used to work like this:
#
# * if couch.master was set to true on one node, then do plain couchdb.
# * if couch.master was not set anywhere, then do bigcouch.
# * if couch.master was set on more than one node, then do bigcouch.
#
# Some of this legacy logic is still supported so that upgrading does
# not unexpectedly turn bigcouch nodes into plain couchdb nodes.
#

if self.couch['master']
  LeapCli::log :warning, "The node property 'couch.master' is deprecated.\n" +
    "   In the future, you must set 'couch.mode' to either 'plain' or 'multimaster'.\n" +
    "   (node '#{self.name}')"
end

couchdb_nodes = nodes_like_me['services' => 'couchdb']

if couchdb_nodes.size > 1
  apply_partial 'services/_couchdb_multimaster.json'
elsif self.couch.mode == "multimaster"
  if self.couch['master']
    # The old deprecated way of specifying plain couch is still being used
    apply_partial 'services/_couchdb_plain.json'
  else
    apply_partial 'services/_couchdb_multimaster.json'
  end
else
  apply_partial 'services/_couchdb_plain.json'
end
