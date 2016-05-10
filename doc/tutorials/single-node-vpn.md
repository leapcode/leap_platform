@title = "Single node VPN tutorial"
@nav_title = "Quick VPN"
@summary = 'Tutorial for setting up a simple VPN provider.'

This tutorial walks you through the initial process of creating and deploying a minimal VPN service provider. Please first complete the [[quick-start]]. This tutorial will pick up where that one left off.

NOTE: For the VPN to work, you must use a real or paravirtualized node, not a local Vagrant node.

Our goal
------------------

We are going to create a minimal LEAP provider offering VPN service.

Our goal is something like this:

    $ leap list
        NODES       SERVICES                       TAGS
        wildebeest  couchdb, webapp, openvpn, tor

Where 'wildebeest' is whatever name you chose for your node in the [[quick-start]].

Add VPN service to the node
--------------------------------------

In order to add [[services => services]] to a node, edit the node's JSON configuration file.

In our example, we would edit `nodes/wildebeest.json`:

    {
      "ip_address": "1.1.1.1",
      "services": ["couchdb", "webapp", "openvpn", "tor"]
    }

Here, we added `openvpn` and `tor` to the node's `services` list. Briefly:

* **openvpn**: nodes with the **openvpn** service will become OpenVPN gateways that clients connect to in order to proxy their internet connection. You can have as many as you want, spread out over as many nodes as you want.
* **tor**: nodes with **tor** service become Tor exit nodes. This is entirely optional, and will add additional bandwidth to your node. If you don't have many VPN users, the added traffic will help create cover traffic for your users. On the down side, this VPN gateway will get flagged as an anonymous proxy and some sites may block traffic from it.

For more details, see the [[services]] overview, or the individual pages for the [[openvpn]] and [[tor]] services.

Add gateway_address to the node
----------------------------------------

VPN gateways require two different IP addresses:

* `ip_address`: This property is used for VPN traffic **egress**. In other words, all VPN traffic appears to come from this IP address. This is also the main IP of the server.
* `openvpn.gateway_address`: This property is used for VPN traffic **ingress**. In other words, clients will connect to this IP address.

The node configuration file should now look like this:

    {
      "ip_address": "1.1.1.1",
      "services": ["couchdb", "webapp", "openvpn", "tor"],
      "openvpn": {
        "gateway_address": "2.2.2.2"
      }
    }

Why two different addresses? Without this, the traffic from one VPN user to another would not be encrypted. This is because the routing table of VPN clients must ensure that packets with a destination of the VPN gateway are sent unmodified and don't get passed through the VPN's encryption.

Generate a Diffie-Hellman file
-------------------------------------------

Next we need to create a Diffie-Hellman parameter file, used for forward secret OpenVPN ciphers. You only need to do this once.

    workstation$ leap cert dh

Feel free to erase the resulting DH file and regenerate it as you please.

Deploy to the node
--------------------

Now you should deploy to your node. This may take a while.

    workstation$ leap deploy

If the deploy was not successful, try to run it again.

Test it out
---------------------------------

First, run:

    workstation$ leap test

Then fire up the Bitmask client, register a new user with your provider, and turn on the VPN connection.

Alternately, you can also manually connect to your VPN gateway using OpenVPN on the command line:

    workstation$ sudo apt install openvpn
    workstation$ leap test init
    workstation$ sudo openvpn --config test/openvpn/default_unlimited.ovpn

Make sure that Bitmask is not connected to the VPN when you run that command.

The name of the test configuration might differ depending on your setup. The test configuration created by `leap test init` includes a client certificate that will expire, so you may need to re-run `leap test init` if it has been a while since you last generated the test configuration.

What do do next
--------------------------------

A VPN provider with a single gateway is kind of limited. You can add as many nodes with service [[openvpn]] as you like. There is no communication among the VPN gateways or with the [[webapp]] or [[couchdb]] nodes, so there is no issue with scaling out the number of gateways.

For example, add some more nodes:

    workstation$ leap node add giraffe ip_address:1.1.1.2 services:openvpn openvpn.gateway_address:2.2.2.3
    workstation$ leap node add rhino ip_address:1.1.1.3 services:openvpn openvpn.gateway_address:2.2.2.4
    workstation$ leap node init giraffe rhino
    workstation$ leap deploy

Now you have three VPN gateways.

One consideration is that you should tag each VPN gateway with a [[location => nodes#locations]]. This helps the client determine which VPN gateway it should connect to by default and will allow the user to choose among gateways based on location.
