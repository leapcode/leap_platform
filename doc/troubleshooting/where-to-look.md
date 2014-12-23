@title = 'Where to look for errors'
@nav_title = 'Where to look'
@toc = true


General
=======

* Please increase verbosity when debugging / filing issues in our issue tracker. You can do this with adding i.e. `-v 5` after the `leap` cmd, i.e. `leap -v 2 deploy`.

Webapp
======

Places to look for errors
-------------------------

* `/var/log/apache2/error.log`
* `/srv/leap/webapp/log/production.log`
* `/var/log/syslog` (watch out for stunnel issues)
* `/var/log/leap/*`

Is haproxy ok ?
---------------


    curl -s -X  GET "http://127.0.0.1:4096"

Is couchdb accessible through stunnel ?
---------------------------------------

* Depending on how many couch nodes you have, increase the port for every test
  (see /etc/haproxy/haproxy.cfg for the server/port mapping):


    curl -s -X  GET "http://127.0.0.1:4000"
    curl -s -X  GET "http://127.0.0.1:4001"
    ...


Check couchdb acl as admin
--------------------------

    mkdir /etc/couchdb
    cat /srv/leap/webapp/config/couchdb.yml.admin  # see username and password
    echo "machine 127.0.0.1 login admin password <PASSWORD>" > /etc/couchdb/couchdb-admin.netrc
    chmod 600 /etc/couchdb/couchdb-admin.netrc

    curl -s --netrc-file /etc/couchdb/couchdb-admin.netrc -X GET "http://127.0.0.1:4096"
    curl -s --netrc-file /etc/couchdb/couchdb-admin.netrc -X GET "http://127.0.0.1:4096/_all_dbs"

Check couchdb acl as unpriviledged user
---------------------------------------

    cat /srv/leap/webapp/config/couchdb.yml  # see username and password
    echo "machine 127.0.0.1 login webapp password <PASSWORD>" > /etc/couchdb/couchdb-webapp.netrc
    chmod 600 /etc/couchdb/couchdb-webapp.netrc

    curl -s --netrc-file /etc/couchdb/couchdb-webapp.netrc -X GET "http://127.0.0.1:4096"
    curl -s --netrc-file /etc/couchdb/couchdb-webapp.netrc -X GET "http://127.0.0.1:4096/_all_dbs"


Check client config files
-------------------------

    https://example.net/provider.json
    https://example.net/1/config/smtp-service.json
    https://example.net/1/config/soledad-service.json
    https://example.net/1/config/eip-service.json


Soledad
=======

    /var/log/soledad.log


Couchdb
=======

Places to look for errors
-------------------------

* `/opt/bigcouch/var/log/bigcouch.log`
* `/var/log/syslog` (watch out for stunnel issues)



Bigcouch membership
-------------------

* All nodes configured for the provider should appear here:

<pre>
    curl -s --netrc-file /etc/couchdb/couchdb.netrc -X GET 'http://127.0.0.1:5986/nodes/_all_docs'
</pre>

* All configured nodes should show up under "cluster_nodes", and the ones online and communicating with each other should appear under "all_nodes". This example output shows the configured cluster nodes `couch1.bitmask.net` and `couch2.bitmask.net`, but `couch2.bitmask.net` is currently not accessible from `couch1.bitmask.net`


<pre>
    curl -s --netrc-file /etc/couchdb/couchdb.netrc 'http://127.0.0.1:5984/_membership'
    {"all_nodes":["bigcouch@couch1.bitmask.net"],"cluster_nodes":["bigcouch@couch1.bitmask.net","bigcouch@couch2.bitmask.net"]}
</pre>

* Sometimes a `/etc/init.d/bigcouch restart` on all nodes is needed, to register new nodes

Databases
---------

* Following output shows all neccessary DBs that should be present. Note that the `user-0123456....` DBs are the data stores for a particular user.

<pre>
    curl -s --netrc-file /etc/couchdb/couchdb.netrc -X GET 'http://127.0.0.1:5984/_all_dbs'
    ["customers","identities","sessions","shared","tickets","tokens","user-0","user-9d34680b01074c75c2ec58c7321f540c","user-9d34680b01074c75c2ec58c7325fb7ff","users"]
</pre>




Design Documents
----------------

* Is User `_design doc` available ?


<pre>
    curl -s --netrc-file /etc/couchdb/couchdb.netrc -X  GET "http://127.0.0.1:5984/users/_design/User"
</pre>

Is couchdb cluster backend accessible through stunnel ?
-------------------------------------------------------

* Find out how many connections are set up for the couchdb cluster backend:

<pre>
    grep "accept = 127.0.0.1" /etc/stunnel/*
</pre>


* Now connect to all of those local endpoints to see if they up. All these tests should return "localhost [127.0.0.1] 4000 (?) open"

<pre>
    nc -v 127.0.0.1 4000
    nc -v 127.0.0.1 4001
    ...
</pre>


MX
==

Places to look for errors
-------------------------

* `/var/log/mail.log`
* `/var/log/leap_mx.log`
* `/var/log/syslog` (watch out for stunnel issues)

Is couchdb accessible through stunnel ?
---------------------------------------

* Depending on how many couch nodes you have, increase the port for every test
  (see /etc/haproxy/haproxy.cfg for the server/port mapping):


    curl -s -X  GET "http://127.0.0.1:4000"
    curl -s -X  GET "http://127.0.0.1:4001"
    ...

Query leap-mx
-------------

* for useraccount


<pre>
    postmap -v -q  "joe@dev.bitmask.net" tcp:localhost:2244
    ...
    postmap: dict_tcp_lookup: send: get jow@dev.bitmask.net
    postmap: dict_tcp_lookup: recv: 200
    ...
</pre>

* for mailalias


<pre>
    postmap -v -q  "joe@dev.bitmask.net" tcp:localhost:4242
    ...
    postmap: dict_tcp_lookup: send: get joe@dev.bitmask.net
    postmap: dict_tcp_lookup: recv: 200 f01bc1c70de7d7d80bc1ad77d987e73a
    postmap: dict_tcp_lookup: found: f01bc1c70de7d7d80bc1ad77d987e73a
    f01bc1c70de7d7d80bc1ad77d987e73a
    ...
</pre>


Check couchdb acl as unpriviledged user
---------------------------------------



    cat /etc/leap/mx.conf  # see username and password
    echo "machine 127.0.0.1 login leap_mx password <PASSWORD>" > /etc/couchdb/couchdb-leap_mx.netrc
    chmod 600 /etc/couchdb/couchdb-leap_mx.netrc

    curl -s --netrc-file /etc/couchdb/couchdb-leap_mx.netrc -X GET "http://127.0.0.1:4096/_all_dbs"   # pick one "user-<hash>" db
    curl -s --netrc-file /etc/couchdb/couchdb-leap_mx.netrc -X GET "http://127.0.0.1:4096/user-de9c77a3d7efbc779c6c20da88e8fb9c"


* you may check multiple times, cause 127.0.0.1:4096 is haproxy load-balancing the different couchdb nodes


Mailspool
---------

* Any file in the leap_mx mailspool longer for a few seconds ?



<pre>
    ls -la /var/mail/vmail/Maildir/cur/
</pre>

* Any mails in postfix mailspool longer than a few seconds ?

<pre>
    mailq
</pre>



Testing mail delivery
---------------------

    swaks -f alice@example.org -t bob@example.net -s mx1.example.net --port 25
    swaks -f varac@cdev.bitmask.net -t varac@cdev.bitmask.net -s chipmonk.cdev.bitmask.net --port 465 --tlsc
    swaks -f alice@example.org -t bob@example.net -s mx1.example.net --port 587 --tls


VPN
===

Places to look for errors
-------------------------

* `/var/log/syslog` (watch out for openvpn issues)


