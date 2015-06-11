@title = "Nodes"
@summary = "Working with nodes, services, tags, and locations."

Node types
================================

Every node has one or more services that determines the node's function within your provider's infrastructure.

When adding a new node to your provider, you should ask yourself four questions:

* **many or few?** Some services benefit from having many nodes, while some services are best run on only one or two nodes.
* **required or optional?** Some services are required, while others can be left out.
* **who does the node communicate with?** Some services communicate very heavily with other particular services. Nodes running these services should be close together.
* **public or private?** Some services communicate with the public internet, while others only need to communicate with other nodes in the infrastructure.

Brief overview of the services:

* **webapp**: The web application. Runs both webapp control panel for users and admins as well as the REST API that the client uses. Needs to communicate heavily with `couchdb` nodes. You need at least one, good to have two for redundancy. The webapp does not get a lot of traffic, so you will not need many.
* **couchdb**: The database for users and user data. You can get away with just one, but for proper redundancy you should have at least three. Communicates heavily with `webapp`, `mx`, and `soledad` nodes.
* **soledad**: Handles the data syncing with clients. Typically combined with `couchdb` service, since it communicates heavily with couchdb.
* **mx**: Incoming and outgoing MX servers. Communicates with the public internet, clients, and `couchdb` nodes.
* **openvpn**: OpenVPN gateway for clients. You need at least one, but want as many as needed to support the bandwidth your users are doing. The `openvpn` nodes are autonomous and don't need to communicate with any other nodes. Often combined with `tor` service.
* **monitor**: Internal service to monitor all the other nodes. Currently, you can have zero or one `monitor` service defined. It is required that the monitor be on the webapp node. It was not designed to be run as a separate node service.
* **tor**: Sets up a tor exit node, unconnected to any other service.
* **dns**: Not yet implemented.

Webapp
-----------------------------------

The webapp node is responsible for both the user face web application and the API that the client interacts with.

Some users can be "admins" with special powers to answer tickets and close accounts. To make an account into an administrator, you need to configure the `webapp.admins` property with an array of user names.

For example, to make users `alice` and `bob` into admins, create a file `services/webapp.json` with the following content:

    {
      "webapp": {
        "admins": ["bob", "alice"]
      }
    }

And then redeploy to all webapp nodes:

    leap deploy webapp

By putting this in `services/webapp.json`, you will ensure that all webapp nodes inherit the value for `webapp.admins`.

Services
================================

What nodes do you need for a provider that offers particular services?

<table class="table table-striped">
<tr>
  <th>Node Type</th>
  <th>VPN Service</th>
  <th>Email Service</th>
  <th>Notes</th>
</tr>
<tr>
  <td>webapp</td>
  <td>required</td>
  <td>required</td>
  <td></td>
</tr>
<tr>
  <td>couchdb</td>
  <td>required</td>
  <td>required</td>
<td></td>
</tr>
<tr>
  <td>soledad</td>
  <td>not used</td>
  <td>required</td>
<td></td>
</tr>
<tr>
  <td>mx</td>
  <td>not used</td>
  <td>required</td>
  <td></td>
</tr>
<tr>
  <td>openvpn</td>
  <td>required</td>
  <td>not used</td>
  <td></td>
</tr>
<tr>
  <td>monitor</td>
  <td>optional</td>
  <td>optional</td>
  <td>This service must be on the webapp node</td>
</tr>
<tr>
  <td>tor</td>
  <td>optional</td>
  <td>optional</td>
  <td></td>
</tr>
</table>

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

Disabling Nodes
=====================================

There are two ways to temporarily disable a node:

**Option 1: disabled environment**

You can assign an environment to the node that marks it as disabled. Then, if you use environment pinning, the node will be ignored when you deploy. For example:

    {
      "environment": "disabled"
    }

Then use `leap env pin ENV` to pin the environment to something other than 'disabled'. This only works if all the other nodes are also assigned to some environment.

**Option 2: enabled == false**

If a node has a property `enabled` set to false, then the `leap` command will skip over the node and pretend that it does not exist. For example:

    {
      "ip_address": "1.1.1.1",
      "services": ["openvpn"],
      "enabled": false
    }

**Options 3: no-deploy**

If the file `/etc/leap/no-deploy` exists on a node, then when you run the commmand `leap deploy` it will halt and prevent a deploy from going through (if the node was going to be included in the deploy).
