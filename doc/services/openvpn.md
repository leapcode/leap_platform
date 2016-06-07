@title = 'openvpn'
@summary = "OpenVPN egress gateways"

Topology
------------------

Currently, `openvpn` service should not be combined with other services on the same node.

Unlike most of the other node types, the `openvpn` nodes do not need access to the database and does not ever communicate with any other nodes (except for the `monitor` node, if used). So, `openvpn` nodes can be placed anywhere without regard to the other nodes.

Configuration
---------------------

*Essential configuration*

* `openvpn.gateway_address`: The address that OpenVPN daemon is bound to and that VPN clients connect to.
* `ip_address`: The main IP of the server, and the egress address for outgoing traffic.

For example:

    {
      "ip_address": "1.1.1.1",
      "openvpn": {
        "gateway_address": "2.2.2.2"
      }
    }

In this example, VPN clients will connect to 2.2.2.2, but their traffic will appear to come from 1.1.1.1.

Why are two IP addresses needed? Without this, traffic between two VPN users on the same gateway will not get encrypted. This is because the VPN on every client must be configured to allow cleartext traffic for the IP address that is the VPN gateway.

*Optional configuration*

Here is the default configuration:

    "openvpn": {
      "configuration": {
        "auth": "SHA1",
        "cipher": "AES-128-CBC",
        "fragment": 1400,
        "keepalive": "10 30",
        "tls-cipher": "DHE-RSA-AES128-SHA",
        "tun-ipv6": true
      },
      "ports": ["80", "443", "53", "1194"],
      "protocols": ["tcp", "udp"]
    }

You may want to change the ports so that only 443 or 80 are used. It is probably best to not modify the `openvpn.configuration` options for now.