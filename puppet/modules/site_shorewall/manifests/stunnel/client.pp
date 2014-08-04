#
# Adds some firewall magic to the stunnel.
#
# Using DNAT, this firewall rule allow a locally running program
# to try to connect to the normal remote IP and remote port of the
# service on another machine, but have this connection magically
# routed through the locally running stunnel client.
#
# The network looks like this:
#
#   From the client's perspective:
#
#   |------- stunnel client --------------|    |---------- stunnel server -----------------------|
#    consumer app -> localhost:accept_port  ->  connect:connect_port -> localhost:original_port
#
#   From the server's perspective:
#
#   |------- stunnel client --------------|    |---------- stunnel server -----------------------|
#                                       ??  ->  *:accept_port -> localhost:connect_port -> service
#

define site_shorewall::stunnel::client(
  $accept_port,
  $connect,
  $connect_port,
  $original_port) {

  include site_shorewall::defaults

  shorewall::rule {
    "stunnel_dnat_${name}":
      action          => 'DNAT',
      source          => '$FW',
      destination     => "\$FW:127.0.0.1:${accept_port}",
      proto           => 'tcp',
      destinationport => $original_port,
      originaldest    => $connect,
      order           => 200
  }
}
