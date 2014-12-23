#######################################################################
###
### NOTE!
###
###  Currently, mirrors do not work! The only thing that works is all
###  nodes multimaster or a single master.
###
#######################################################################
#
# custom logic for couchdb json resolution
# ============================================
#
# There are three modes for a node:
#
# Multimaster
# -----------
#
#    Multimaster uses bigcouch (soon to use couchdb in replication mode
#    similar to bigcouch).
#
#    Use "multimaster" mode when:
#
#     * multiple nodes are marked couch.master
#     * OR no nodes are marked couch.master
#
# Master
# ------
#
#    Master uses plain couchdb that is readable and writable.
#
#    Use "master" mode when:
#
#     * Exactly one node, this one, is marked as master.
#
# Mirror
# ------
#
#    Mirror creates a read-only copy of the database. It uses plain coucdhb
#    with legacy couchdb replication (http based).
#
#    This does not currently work, because http replication can't handle
#    the number of user databases.
#
#    Use "mirror" mode when:
#
#     * some nodes are marked couch.master
#     * AND this node is not a master
#

master_count = nodes_like_me['services' => 'couchdb']['couch.master' => true].size

if master_count == 0
  apply_partial 'services/_couchdb_multimaster.json'
elsif couch.master && master_count > 1
  apply_partial 'services/_couchdb_multimaster.json'
elsif couch.master && master_count == 1
  apply_partial 'services/_couchdb_master.json'
else
  apply_partial 'services/_couchdb_mirror.json'
end
