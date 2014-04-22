@title = "LEAP Platform Guide"
@nav_title = "Guide"

Services
================================

Every node has one or more services that determines the node's function within your provider's infrastructure.

When adding a new node to your provider, you should ask yourself four questions:

* **many or few?** Some services benefit from having many nodes, while some services are best run on only one or two nodes.
* **required or optional?** Some services are required, while others can be left out.
* **who does the node communicate with?** Some services communicate very heavily with other particular services. Nodes running these services should be close together.
* **public or private?** Some services communicate with the public internet, while others only need to communicate with other nodes in the infrastructure.

Brief overview of the services:

* **webapp**: The web application. Runs both webapp control panel for users and admins as well as the REST API that the client uses. Needs to communicate heavily with `couchdb` nodes. You need at least one, good to have two for redundancy. The webapp does not get a lot of traffic, so you will not need many.
* **couchdb**: The database for users and user data. You can get away with just one, but for proper redundancy you should have at least three. Communicates heavily with `webapp` and `mx` nodes.
* **soledad**: Handles the data syncing with clients. Typically combined with `couchdb` service, since it communicates heavily with couchdb. (not currently in stable release)
* **mx**: Incoming and outgoing MX servers. Communicates with the public internet, clients, and `couchdb` nodes. (not currently in stable release)
* **openvpn**: OpenVPN gateway for clients. You need at least one, but want as many as needed to support the bandwidth your users are doing. The `openvpn` nodes are autonomous and don't need to communicate with any other nodes. Often combined with `tor` service.
* **monitor**: Internal service to monitor all the other nodes. Currently, you can have zero or one `monitor` nodes.
* **tor**: Sets up a tor exit node, unconnected to any other service.
* **dns**: Not yet implemented.

Locations
================================

All nodes should have a `location.name` specified, and optionally additional information about the location, like the time zone. This location information is used for two things:

* Determine which nodes can, or must, communicate with one another via a local network. The way some virtualization environments work, like OpenStack, requires that nodes communicate via the local network if they are on the same network.
* Allows the client to prefer connections to nodes that are closer in physical proximity to the user. This is particularly important for OpenVPN nodes.

The location stanza in a node's config file looks like this:

    {
      "location": {
        "id": "ankara",
        "name": "Ankara",
        "country_code": "TR",
        "timezone": "+2",
        "hemisphere": "N"
      }
    }

The fields:

* `id`: An internal handle to use for this location. If two nodes have match `location.id`, then they are treated as being on a local network with one another. This value defaults to downcase and underscore of `location.name`.
* `name`: Can be anything, might be displayed to the user in the client if they choose to manually select a gateway.
* `country_code`: The [ISO 3166-1](https://en.wikipedia.org/wiki/ISO_3166-1) two letter country code.
* `timezone`: The timezone expressed as an offset from UTC (in standard time, not daylight savings). You can look up the timezone using this [handy map](http://www.timeanddate.com/time/map/).
* `hemisphere`: This should be "S" for all servers in South America, Africa, or Australia. Otherwise, this should be "N".

These location options are very imprecise, but good enough for most usage. The client often does not know its own location precisely either. Instead, the client makes an educated guess at location based on the OS's timezone and locale.

If you have multiple nodes in a single location, it is best to use a tag for the location. For example:

`tags/ankara.json`:

    {
      "location": {
        "name": "Ankara",
        "country_code": "TR",
        "timezone": "+2",
        "hemisphere": "N"
      }
    }

`nodes/vpngateway.json`:

    {
      "services": "openvpn",
      "tags": ["production", "ankara"],
      "ip_address": "1.1.1.1",
      "openvpn": {
        "gateway_address": "1.1.1.2"
      }
    }

Unless you are using OpenStack or AWS, setting `location` for nodes is not required. It is, however, highly recommended.

Working with SSH
================================

Whenever the `leap` command nees to push changes to a node or gather information from a node, it tunnels this command over SSH. Another way to put this: the security of your servers rests entirely on SSH. Because of this, it is important that you understand how `leap` uses SSH.

SSH related files
-------------------------------

Assuming your provider directory is called 'provider':

* `provider/nodes/crow/crow_ssh.pub` -- The public SSH host key for node 'crow'.
* `provider/users/alice/alice_ssh.pub` -- The public SSH user key for user 'alice'. Anyone with the private key that corresponds to this public key will have root access to all nodes.
* `provider/files/ssh/known_hosts` -- An autogenerated known_hosts, built from combining `provider/nodes/*/*_ssh.pub`. You must not edit this file directly. If you need to change it, remove or change one of the files that is used to generate `known_hosts` and then run `leap compile`.
* `provider/files/ssh/authorized_keys` -- An autogenerated list of all the user SSH keys with root access to the notes. It is created from `provider/users/*/*_ssh.pub`. You must not edit this file directly. If you need to change it, remove or change one of the files that is used to generate `authorized_keys` and then run `leap compile`.

All of these files should be committed to source control.

If you rename, remove, or add a node with `leap node [mv|add|rm]` the SSH key files and the `known_hosts` file will get properly updated.

SSH and local nodes
-----------------------------

Local nodes are run as Vagrant virtual machines. The `leap` command handles SSH slightly differently for these nodes.

Basically, all the SSH security is turned off for local nodes. Since local nodes only exist for a short time on your computer and can't be reached from the internet, this is not a problem.

Specifically, for local nodes:

1. `known_hosts` is never updated with local node keys, since the SSH public key of a local node is different for each user.
2. `leap` entirely skips the checking of host keys when connecting with a local node.
3. `leap` adds the public Vagrant SSH key to the list of SSH keys for a user. The public Vagrant SSH key is a shared and insecure key that has root access to most Vagrant virtual machines.

When SSH host key changes
-------------------------------

If the host key for a node has changed, you will get an error "WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED".

To fix this, you need to remove the file `files/nodes/stompy/stompy_ssh.pub` and run `leap node init stompy`, where the node's name is 'stompy'. **Only do this if you are ABSOLUTELY CERTAIN that the node's SSH host key has changed**.

Changing the SSH port
--------------------------------

Suppose you have a node `blinky` that has SSH listening on port 22 and you want to make it port 2200.

First, modify the configuration for `blinky` to specify the variable `ssh.port` as 2200. Usually, this is done in `common.json` or in a tag file.

For example, you could put this in `tags/production.json`:

    {
      "ssh": {
        "port": 2200
      }
    }

Run `leap compile` and open `hiera/blinky.yaml` to confirm that `ssh.port` is set to 2200. The port number must be specified as a number, not a string (no quotes).

Then, you need to deploy this change so that SSH will bind to 2200. You cannot simply run `leap deploy blinky` because this command will default to using the variable `ssh.port` which is now `2200` but SSH on the node is still bound to 22.

So, you manually override the port in the deploy command, using the old port:

    leap deploy --port 22 blinky

Afterwards, SSH on `blinky` should be listening on port 2200 and you can just run `leap deploy blinky` from then on.

X.509 Certificates
================================

Configuration options
-------------------------------------------

The `ca` option in provider.json provides settings used when generating CAs and certificates. The defaults are as follows:

    {
      "ca": {
        "name": "= global.provider.ca.organization + ' Root CA'",
        "organization": "= global.provider.name[global.provider.default_language]",
        "organizational_unit": "= 'https://' + global.provider.domain",
        "bit_size": 4096,
        "digest": "SHA256",
        "life_span": "10y",
        "server_certificates": {
          "bit_size": 2048,
          "digest": "SHA256",
          "life_span": "1y"
        },
        "client_certificates": {
          "bit_size": 2048,
          "digest": "SHA256",
          "life_span": "2m",
          "limited_prefix": "LIMITED",
          "unlimited_prefix": "UNLIMITED"
        }
      }
    }

You should not need to override these defaults in your own provider.json, but you can if you want to. To see what values are used for your provider, run `leap inspect provider.json`.

NOTE: A certificate `bit_size` greater than 2048 will probably not be recognized by most commercial CAs.

Certificate Authorities
-----------------------------------------

There are three x.509 certificate authorities (CA) associated with your provider:

1. **Commercial CA:** It is strongly recommended that you purchase a commercial cert for your primary domain. The goal of platform is to not depend on the commercial CA system, but it does increase security and usability if you purchase a certificate. The cert for the commercial CA must live at `files/cert/commercial_ca.crt`.
2. **Server CA:** This is a self-signed CA responsible for signing all the **server** certificates. The private key lives at `files/ca/ca.key` and the public cert lives at `files/ca/ca.crt`. The key is very sensitive information and must be kept private. The public cert is distributed publicly.
3. **Client CA:** This is a self-signed CA responsible for signing all the **client** certificates. The private key lives at `files/ca/client_ca.key` and the public cert lives at `files/ca/client_ca.crt`. Neither file is distribute publicly. It is not a big deal if the private key for the client CA is compromised, you can just generate a new one and re-deploy.

To generate both the Server CA and the Client CA, run the command:

    leap cert ca

Server certificates
-----------------------------------

Most every server in your service provider will have a x.509 certificate, generated by the `leap` command using the Server CA. Whenever you modify any settings of a node that might affect it's certificate (like changing the IP address, hostname, or settings in provider.json), you can magically regenerate all the certs that need to be regenerated with this command:

    leap cert update

Run `leap help cert update` for notes on usage options.

Because the server certificates are generated locally on your personal machine, the private key for the Server CA need never be put on any server. It is up to you to keep this file secure.

Client certificates
--------------------------------

Every leap client gets its own time-limited client certificate. This cert is use to connect to the OpenVPN gateway (and probably other things in the future). It is generated on the fly by the webapp using the Client CA.

To make this work, the private key of the Client CA is made available to the webapp. This might seem bad, but compromise of the Client CA simply allows the attacker to use the OpenVPN gateways without paying. In the future, we plan to add a command to automatically regenerate the Client CA periodically.

There are two types of client certificates: limited and unlimited. A client using a limited cert will have its bandwidth limited to the rate specified by `provider.service.bandwidth_limit` (in Bytes per second). An unlimited cert is given to the user if they authenticate and the user's service level matches one configured in `provider.service.levels` without bandwidth limits. Otherwise, the user is given a limited client cert.

Commercial certificates
-----------------------------------

We strongly recommend that you use a commercial signed server certificate for your primary domain (in other words, a certificate with a common name matching whatever you have configured for `provider.domain`). This provides several benefits:

1. When users visit your website, they don't get a scary notice that something is wrong.
2. When a user runs the LEAP client, selecting your service provider will not cause a warning message.
3. When other providers first discover your provider, they are more likely to trust your provider key if it is fetched over a commercially verified link.

The LEAP platform is designed so that it assumes you are using a commercial cert for the primary domain of your provider, but all other servers are assumed to use non-commercial certs signed by the Server CA you create.

To generate a CSR, run:

    leap cert csr

This command will generate the CSR and private key matching `provider.domain` (you can change the domain with `--domain=DOMAIN` switch). It also generates a server certificate signed with the Server CA. You should delete this certificate and replace it with a real one once it is created by your commercial CA.

The related commercial cert files are:

    files/
      certs/
        domain.org.crt    # Server certificate for domain.org, obtained by commercial CA.
        domain.org.csr    # Certificate signing request
        domain.org.key    # Private key for you certificate
        commercial_ca.crt # The CA cert obtained from the commercial CA.

The private key file is extremely sensitive and care should be taken with its provenance.

If your commercial CA has a chained CA cert, you should be OK if you just put the **last** cert in the chain into the `commercial_ca.crt` file. This only works if the other CAs in the chain have certs in the debian package `ca-certificates`, which is the case for almost all CAs.

If you want to add additional fields to the CSR, like country, city, or locality, you can configure these values in provider.json like so:

      "ca": {
        "server_certificates": {
          "country": "US",
          "state": "Washington",
          "locality": "Seattle"
        }
      }

If they are not present, the CSR will be created without them.

Facts
==============================

There are a few cases when we must gather internal data from a node before we can successfully deploy to other nodes. This is what `facts.json` is for. It stores a snapshot of certain facts about each node, as needed. Entries in `facts.json` are updated automatically when you initialize, rename, or remove a node. To manually force a full update of `facts.json`, run:

    leap facts update FILTER

Run `leap help facts update` for more information.

The file `facts.json` should be committed to source control. You might not have a `facts.json` if one is not required for your provider.
