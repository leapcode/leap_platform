@nav_title = "Services"
@title = "Guide to node services"
@summary = ""
@toc = true

# Introduction

Every node (server) must have one or more `services` defined that determines what role the node performs. For example:

    workstation$ cat nodes/stallman.json
    {
      "ip_address": "199.99.99.1",
      "services": ["webapp", "tor"]
    }

Here are common questions to ask when adding a new node to your provider:

* **many or few?** Some services benefit from having many nodes, while some services are best run on only one or two nodes.
* **required or optional?** Some services are required, while others can be left out.
* **who does the node communicate with?** Some services communicate very heavily with other particular services. Nodes running these services should be close together.
* **public or private network?** Some services communicate with the public internet, while others only need to communicate with other nodes in the infrastructure.

# Available services

<table class="table table-striped">
<tr>
  <th>Service</th>
  <th>VPN</th>
  <th>Email</th>
  <th>Notes</th>
</tr>
<tr>
  <td>webapp</td>
  <td><i class="fa fa-circle"></i></td>
  <td><i class="fa fa-circle"></i></td>
  <td>User control panel, provider API, and support system.</td>
</tr>
<tr>
  <td>couchdb</td>
  <td><i class="fa fa-circle"></i></td>
  <td><i class="fa fa-circle"></i></td>
  <td>Data storage for everything. Private node.</td>
<td></td>
</tr>
<tr>
  <td>soledad</td>
  <td><i class="fa fa-circle-o"></i></td>
  <td><i class="fa fa-circle"></i></td>
  <td>User data synchronization daemon. Usually paired with <code>couchdb</code> nodes.</td>
<td></td>
</tr>
<tr>
  <td>mx</td>
  <td><i class="fa fa-circle-o"></i></td>
  <td><i class="fa fa-circle"></i></td>
  <td>Incoming and outgoing MX servers.</td>
</tr>
<tr>
  <td>openvpn</td>
  <td><i class="fa fa-circle"></i></td>
  <td><i class="fa fa-circle-o"></i></td>
  <td>OpenVPN gateways.</td>
</tr>
<tr>
  <td>monitor</td>
  <td><i class="fa fa-dot-circle-o"></i></td>
  <td><i class="fa fa-dot-circle-o"></i></td>
  <td>Nagios monitoring. This service must be on the webapp node.</td>
</tr>
<tr>
  <td>tor</td>
  <td><i class="fa fa-dot-circle-o"></i></td>
  <td><i class="fa fa-dot-circle-o"></i></td>
  <td>Tor exit node.</td>
</tr>
</table>

Key: <i class="fa fa-circle"> Required</i>, <i class="fa fa-dot-circle-o"> Optional</i>, <i class="fa fa-circle-o"> Not Used</i>

<%= child_summaries %>