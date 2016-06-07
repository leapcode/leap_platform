@title = 'tor'
@summary = 'Tor exit node or hidden service'

Topology
------------------------

Nodes with `tor` service will run a Tor exit or hidden service, depending on what other service it is paired with:

* `tor` + `openvpn`: when combined with `openvpn` nodes, `tor` will create a Tor exit node to provide extra cover traffic for the VPN. This can be especially useful if there are VPN gateways without much traffic.
* `tor` + `webapp`: when combined with a `webapp` node, the `tor` service will make the webapp and the API available via .onion hidden service.
* `tor` stand alone: a regular Tor exit node.

If activated, you can list the hidden service .onion addresses this way:

   leap ls --print tor.hidden_service.address tor

Then just add '.onion' to the end of the printed addresses.

Configuration
------------------------------

* `tor.bandwidth_rate`: the max bandwidth allocated to Tor, in KB per second, when used as an exit node.

For example:

    {
      "tor": {
        "bandwidth_rate": 6550
      }
    }


