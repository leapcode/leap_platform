@title = "CouchDB"

Rebalance Cluster
=================

Bigcouch currently does not have automatic rebalancing.
It will probably be added after merging into couchdb.
If you add a node, or remove one node from the cluster,

. make sure you have a backup of all DBs !

    /srv/leap/couchdb/scripts/couchdb_dumpall.sh


. delete all dbs
. shut down old node
. check the couchdb members

    curl -s —netrc-file /etc/couchdb/couchdb.netrc -X GET http://127.0.0.1:5986/nodes/_all_docs
    curl -s —netrc-file /etc/couchdb/couchdb.netrc http://127.0.0.1:5984/_membership


. remove bigcouch from all nodes

    apt-get --purge remove bigcouch


. deploy to all couch nodes

    leap deploy development +couchdb

. most likely, deploy will fail because bigcouch will complain about not all nodes beeing connected. Lets the deploy finish, restart the bigcouch service on all nodes and re-deploy:

    /etc/init.d/bigcouch restart


. restore the backup

     /srv/leap/couchdb/scripts/couchdb_restoreall.sh


Re-enabling blocked account
===========================

When a user account gets destroyed from the webapp, there's still a leftover doc in the identities db so other ppl can't claim that account without admin's intervention. Here's how you delete that doc and therefore enable registration for that particular account again:

. grep the identities db for the email address:

    curl -s --netrc-file /etc/couchdb/couchdb.netrc -X GET http://127.0.0.1:5984/identities/_all_docs?include_docs=true|grep test_127@bitmask.net


. lookup "id" and "rev" to delete the doc:

    curl -s --netrc-file /etc/couchdb/couchdb.netrc -X DELETE 'http://127.0.0.1:5984/identities/b25cf10f935b58088f0d547fca823265?rev=2-715a9beba597a2ab01851676f12c3e4a'



