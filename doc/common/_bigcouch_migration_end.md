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
