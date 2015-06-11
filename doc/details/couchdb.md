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


How to find out which userstore belongs to which identity ?
===========================================================

    /usr/bin/curl -s --netrc-file /etc/couchdb/couchdb.netrc '127.0.0.1:5984/identities/_all_docs?include_docs=true' | grep testuser

    {"id":"665e004870ee17aa4c94331ff3ecb173","key":"665e004870ee17aa4c94331ff3ecb173","value":{"rev":"2-2e335a75c4b79a5c2ef5c9950706fe1b"},"doc":{"_id":"665e004870ee17aa4c94331ff3ecb173","_rev":"2-2e335a75c4b79a5c2ef5c9950706fe1b","user_id":"665e004870ee17aa4c94331ff3cd59eb","address":"testuser@example.org","destination":"testuser@example.org","keys": ...

* search for the "user_id" field
* in this example testuser@example.org uses the database user-665e004870ee17aa4c94331ff3cd59eb


How much disk space is used by a userstore
==========================================

Beware that this returns the uncompacted disk size (see http://wiki.apache.org/couchdb/Compaction)

    echo "`curl --netrc -s -X GET 'http://127.0.0.1:5984/user-dcd6492d74b90967b6b874100b7dbfcf'|json_pp|grep disk_size|cut -d: -f 2`/1024"|bc

