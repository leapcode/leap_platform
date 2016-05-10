@title = 'Single node email tutorial'
@nav_title = 'Quick email'
@summary = 'Tutorial for setting up a simple email provider.'

This tutorial walks you through the initial process of creating and deploying a minimal email service provider. Please first complete the [[quick-start]]. This tutorial will pick up where that one left off.

Our goal
------------------

We are going to create a minimal LEAP provider offering email service.

Our goal is something like this:

    $ leap list
        NODES       SERVICES                       TAGS
        wildebeest  couchdb, mx, soledad, webapp

Where 'wildebeest' is whatever name you chose for your node in the [[quick-start]].

Add email services to the node
--------------------------------------

In order to add [[services => services]] to a node, edit the node's JSON configuration file.

In our example, we would edit `nodes/wildebeest.json`:

    {
      "ip_address": "1.1.1.1",
      "services": ["couchdb", "webapp", "mx", "soledad"]
    }

Here, we added `mx` and `soledad` to the node's `services` list. Briefly:

* **mx**: nodes with the **mx** service will run postfix mail transfer agent, and are able to receive and relay email on behalf of your domain. You can have as many as you want, spread out over as many nodes as you want.
* **soledad**: nodes with **soledad** service run the server-side daemon that allows the client to synchronize a user's personal data store among their devices. Currently, **soledad** only runs on nodes that are also **couchdb** nodes.

For more details, see the [[services]] overview, or the individual pages for the [[mx]] and [[soledad]] services.

Deploy to the node
--------------------

Now you should deploy to your node.

    workstation$ leap deploy

Setup DNS
----------------------------

There are several important DNS entries that all email providers should have:

* SPF (Sender Policy Framework): With SPF, an email provider advertises in their DNS which servers should be allowed to relay email on behalf of your domain.
* DKIM (DomainKey Identified Mail): With DKIM, an email provider is able to vouch for the validity of certain headers in outgoing mail, allowing the receiving provider to have more confidence in these values when processing the message for spam or abuse.

In order to take advantage of SPF and DKIM, run this command:

    workstation$ leap compile zone

Then take the output of that command and merge it with the DNS zone file for your domain.

CAUTION: the output of `leap compile zone` is not a complete zone file since it is missing a serial number. You will need to manually merge it with your existing zone file.

Test it out
---------------------------------

First, run:

    workstation# leap test

Then fire up the bitmask client, register a new user with your provider, and try sending and receiving email.
