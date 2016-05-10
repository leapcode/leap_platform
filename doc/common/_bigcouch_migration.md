@title = "Migrating from BigCouch to plain CouchDB"

Here are the steps needed to replace BigCouch with CouchDB.

At the end of this process, you will have just *one* node with `services` property equal to `couchdb`. If you had a BigCouch cluster before, you will be removing all but one of those machines to consolidate them into one CouchDB machine.

1. if you have multiple nodes with the `couchdb` service on them, pick one of them to be your CouchDB server, and remove the service from the others. If these machines were only doing BigCouch before, you can remove the nodes completely with `leap node rm <nodename>` and then you can decommission the servers

1. put the webapp into [[maintenance mode => webapp#maintenance-mode]]

1. turn off daemons that access the database. For example:

    ```
    workstation$ leap ssh <each soledad-node>
    server# /etc/init.d/soledad-server stop

    workstation$ leap ssh <mx-node>
    server# /etc/init.d/postfix stop
    server# /etc/init.d/leap-mx stop

    workstation$ leap ssh <webapp-node>
    server# /etc/init.d/nickserver stop
    ```

    Alternately, you can create a temporary firewall rule to block access (run on couchdb server):

    ```
    server# iptables -A INPUT -p tcp --dport 5984 --jump REJECT
    ```

1. remove orphaned databases and do a backup of all remaining, active databases. This can take some time and will place several hundred megabytes of data into /var/backups/couchdb. The size and time depends on how many users there are on your system. For example, 15k users took approximately 25 minutes and 308M of space:

    ```
    workstation$ leap ssh <couchdb-node>
    server# cd /srv/leap/couchdb/scripts
    server# ./cleanup-user-dbs
    server# time ./couchdb_dumpall.sh
    ```

1. stop bigcouch:

    ```
    server# /etc/init.d/bigcouch stop
    server# pkill epmd
    ```

1. remove bigcouch:

    ```
    server# apt-get remove bigcouch
    ```

1. configure your couch node to use plain couchdb instead of bigcouch, you can do this by editing nodes/<couch-node>.json, look for this section:

  ```
  "couch": {
    "mode": "plain"
  }
  ```

  change it, so it looks like this instead:

  ```
  "couch": {
    "mode": "plain",
    "pwhash_alg": "pbkdf2"
  }
  ```

1. deploy to the couch node:

    ```
    workstation$ leap deploy <couchdb-node>
    ```

    If you used the iptables method of blocking access to couchdb, you need to run it again because the deploy just overwrote all the iptables rules:

    ```
    server# iptables -A INPUT -p tcp --dport 5984 --jump REJECT
    ```

1. restore the backup, this will take approximately the same amount of time as the backup took above:

    ```
    server# cd /srv/leap/couchdb/scripts
    server# time ./couchdb_restoreall.sh
    ```

1. start services again that were stopped in the beginning:

    ```
    workstation$ leap ssh soledad-nodes
    server# /etc/init.d/soledad-server start

    workstation$ leap ssh mx-node
    server# /etc/init.d/postfix start
    server# /etc/init.d/leap-mx start

    workstation$ leap ssh webapp
    server# /etc/init.d/nickserver start
    ```

    Or, alternately, if you set up the firewall rule instead, now remove it:

    ```
    server# iptables -D INPUT -p tcp --dport 5984 --jump REJECT
    ```

1. check if everything is working, including running the test on your deployment machine:

    ```
    workstation$ leap test
    ```

1. Remove old bigcouch data dir `/opt` after you double checked everything is in place

1. Relax, enjoy a refreshing beverage.
