#
# custom logic for couchdb json resolution
# ============================================
#
# bigcouch is no longer maintained, so now couchdb is required...
# no matter what!
#

if self.couch['master']
  LeapCli::log :warning, %("The node property {couch.master:true} is deprecated.\n) +
    %(   Only {couch.mode:plain} is supported. (node #{self.name}))
end

couchdb_nodes = nodes_like_me['services' => 'couchdb']

if couchdb_nodes.size > 1
  LeapCli::log :error, "Having multiple nodes with {services:couchdb} is no longer supported (nodes #{couchdb_nodes.keys.join(', ')})."
elsif self.couch.mode == "multimaster"
  LeapCli::log :error, "Nodes with {couch.mode:multimaster} are no longer supported (node #{self.name})."
end

#
# This is needed for the "test" that creates and removes the storage db
# for test_user_email. If that test is removed, then this is no longer
# necessary:
#
apply_partial('_api_tester')