@title = "Ports"
@summary = "The required open ports for different services."
@toc = true

There are many different ports that must be open in order for the LEAP platform to work. Some ports must be *publicly open*, meaning that these should be accessible from the public internet. Other ports are *privately open*, meaning that they must be accessible to sysadmins or to the other nodes in the provider's infrastructure.

Every node already includes a host-based firewall. However, if your network has its own firewall, you need to make sure that these ports are not blocked.

Publicly open ports
--------------------------------

<table class="table table-striped">
<tr>
  <th>Name</th>
  <th>Node Type</th>
  <th>Default</th>
  <th>Notes</th>
</tr>
<tr>
  <td>SMTP</td>
  <td>mx</td>
  <td>25</td>
  <td>This is required for all server-to-server SMTP email relay. This is not configurable.</td>
</tr>
<tr>
  <td>HTTP</td>
  <td>webapp</td>
  <td>80</td>
  <td>Although no actual services are available over port 80, it should be unblocked so that the web app can redirect to port 443. This is not configurable.</td>
</tr>
<tr>
  <td>HTTPS</td>
  <td>webapp</td>
  <td>443</td>
  <td>The web application is available over this port. This is not configurable.</td>
</tr>
<tr>
  <td>SMTPS</td>
  <td>mx</td>
  <td>465</td>
  <td>The client uses this port to submit outgoing email messages via SMTP over TLS. There is no easy way to change this, although you can create a custom <code>files/service-definitions/v1/smtp-service.json.erb</code> to do so. This will be changed to port 443 in the future.</td>
</tr>
<tr>
  <td>Soledad</td>
  <td>soledad</td>
  <td>2323</td>
  <td>The client uses this port to synchronize its storage data. This can be changed via the configuration property <code>soledad.port</code>. This will be changed to port 443 in the future.</td>
</tr>
<tr>
  <td>Nicknym</td>
  <td>webapp</td>
  <td>6425</td>
  <td>The client uses this port for discovering public keys. This can be changed via the configuration property <code>nickserver.port</code>. This will be changed to port 443 in the future.</td>
</tr>
<tr>
  <td>OpenVPN</td>
  <td>openvpn</td>
  <td>80, 443, 53, 1194</td>
  <td>By default, OpenVPN gateways will listen on all those ports. This can be changed via the configuration property <code>openvpn.ports</code>. Note that these ports must be open for <code>openvpn.gateway_address</code>, not for <code>ip_address</code>.</td>
</tr>
<tr>
  <td>API</td>
  <td>webapp</td>
  <td>4430</td>
  <td>Currently, the provider API is accessible via this port. In the future, the default will be changed to 443. For now, this can be changed via the configuration property <code>api.port</code>.</td>
</tr>
</table>

Privately open ports
---------------------------------------

<table class="table table-striped">
<tr>
  <th>Name</th>
  <th>Node Type</th>
  <th>Default</th>
  <th>Notes</th>
</tr>
<tr>
  <td>SSH</td>
  <td>all</td>
  <td>22</td>
  <td>This is the port that the sshd is bound to for the node. You can modify this using the configuration property <code>ssh.port</code>. It is important that this port is never blocked, or you will lose access to deploy to this node.</td>
</tr>
<tr>
  <td>Stunnel</td>
  <td>all</td>
  <td>10000-20000</td>
  <td>This is the range of ports that might be used for the encrypted stunnel connections between two nodes. These port numbers are automatically generated, but will fall somewhere in the specified range.</td>
</tr>
</table>

