@title = "couchdb"
@summary = "Data storage for all user data."

Topology
------------------------

Required:

* Nodes with `couchdb` service must also have `soledad` service, if email is enabled.

Suggested:

* Nodes with `couchdb` service communicate heavily with `webapp` and `mx`.

`couchdb` nodes do not need to be reachable from the public internet, although the `soledad` service does require this.

Configuration
----------------------------

### Nighly dumps

You can do a nightly couchdb data dump by adding this to your node config:

    "couch": {
      "backup": true
    }

Data will get dumped to `/var/backups/couchdb`.

### Plain CouchDB

BigCouch is not supported on Platform version 0.8 and higher: only plain CouchDB is possible. For earlier versions, you must do this in order to use plain CouchDB:

    "couch": {
      "master": true,
      "pwhash_alg": "pbkdf2"
    }

Various Tasks
-------------------------------------------------

### Re-enabling blocked account

When a user account gets destroyed from the webapp, there's still a leftover doc in the identities db so other people can't claim that account without an admin's intervention. You can remove this username reservation through the webapp.

However, here is how you could do it manually, if you wanted to:

grep the identities db for the email address:

    curl -s --netrc-file /etc/couchdb/couchdb.netrc -X GET http://127.0.0.1:5984/identities/_all_docs?include_docs=true|grep test_127@bitmask.net

lookup "id" and "rev" to delete the doc:

    curl -s --netrc-file /etc/couchdb/couchdb.netrc -X DELETE 'http://127.0.0.1:5984/identities/b25cf10f935b58088f0d547fca823265?rev=2-715a9beba597a2ab01851676f12c3e4a'

### How to find out which userstore belongs to which identity?

    /usr/bin/curl -s --netrc-file /etc/couchdb/couchdb.netrc '127.0.0.1:5984/identities/_all_docs?include_docs=true' | grep testuser

    {"id":"665e004870ee17aa4c94331ff3ecb173","key":"665e004870ee17aa4c94331ff3ecb173","value":{"rev":"2-2e335a75c4b79a5c2ef5c9950706fe1b"},"doc":{"_id":"665e004870ee17aa4c94331ff3ecb173","_rev":"2-2e335a75c4b79a5c2ef5c9950706fe1b","user_id":"665e004870ee17aa4c94331ff3cd59eb","address":"testuser@example.org","destination":"testuser@example.org","keys": ...

* search for the "user_id" field
* in this example testuser@example.org uses the database user-665e004870ee17aa4c94331ff3cd59eb


### How much disk space is used by a userstore

Beware that this returns the uncompacted disk size (see http://wiki.apache.org/couchdb/Compaction)

    echo "`curl --netrc -s -X GET 'http://127.0.0.1:5984/user-dcd6492d74b90967b6b874100b7dbfcf'|json_pp|grep disk_size|cut -d: -f 2`/1024"|bc


Deprecated BigCouch Tasks
-----------------------------------------

As of release 0.8, the LEAP platform no longer supports BigCouch. This information is kept here for historical reference.

### Rebalance Cluster

Bigcouch currently does not have automatic rebalancing.
It will probably be added after merging into couchdb.
If you add a node, or remove one node from the cluster,

1. make sure you have a backup of all DBs !

1. put the webapp into [[maintenance mode => services/webapp#maintenance-mode]]

1. Stop all services that access the database:

    ```
    workstation$ leap ssh soledad-nodes
    server# /etc/init.d/soledad-server stop

    workstation$ leap ssh mx-node
    server# /etc/init.d/postfix stop
    server# /etc/init.d/leap-mx stop

    workstation$ leap ssh webapp
    server# /etc/init.d/nickserver stop
    ```

    Alternately, you can create a temporary firewall rule to block access (run on couchdb server):

    ```
    server# iptables -A INPUT -p tcp --dport 5984 --jump REJECT
    ```

1. dump the dbs:

    ```
    cd /srv/leap/couchdb/scripts
    time ./couchdb_dumpall.sh
    ```

1. delete all dbs

1. shut down old node

1. check the couchdb members

    ```
    curl -s —netrc-file /etc/couchdb/couchdb.netrc -X GET http://127.0.0.1:5986/nodes/_all_docs
    curl -s —netrc-file /etc/couchdb/couchdb.netrc http://127.0.0.1:5984/_membership
    ```

1. remove bigcouch from all nodes

    ```
    apt-get --purge remove bigcouch
    ```

1. deploy to all couch nodes

    ```
    leap deploy couchdb
    ```

1. most likely, deploy will fail because bigcouch will complain about not all nodes beeing connected. Let the deploy finish, restart the bigcouch service on all nodes and re-deploy:

    ```
    /etc/init.d/bigcouch restart
    ```

1. restore the backup

    ```
    cd /srv/leap/couchdb/scripts
    time ./couchdb_restoreall.sh
    ```

### Migrating from BigCouch to plain CouchDB

<%= render :partial => 'docs/platform/common/bigcouch_migration_begin.md' %>


<%= render :partial => 'docs/platform/common/bigcouch_migration_end.md' %>


<%= render :partial => 'docs/platform/common/bigcouch_migration_finish.md' %>
