#
# Cipher discussion
# ================================
#
# We want to specify explicit values for the crypto options to prevent a MiTM from forcing
# a weaker cipher. These should be set in both the server and the client ('auth' and 'cipher'
# MUST be the same on both ends or no data will get transmitted).
#
# tls-cipher DHE-RSA-AES128-SHA
#
#   dkg: For the TLS control channel, we want to make sure we choose a
#   key exchange mechanism that has PFS (meaning probably some form of ephemeral
#   Diffie-Hellman key exchange), and that uses a standard, well-tested cipher
#   (I recommend AES, and 128 bits is probably fine, since there are some known
#   weaknesses in the 192- and 256-bit key schedules). That leaves us with the
#   choice of public key algorithms: /usr/sbin/openvpn --show-tls | grep DHE |
#   grep AES128 | grep GCM.
#
#   elijah:
#   I could not get any of these working:
#     * openvpn --show-tls | grep GCM
#     * openvpn --show-tls | grep DHE | grep AES128 | grep SHA256
#   so, i went with this:
#     * openvpn --show-tls | grep DHE | grep AES128 | grep -v SHA256 | grep -v GCM
#   Also, i couldn't get any of the elliptical curve algorithms to work. Not sure how
#   our cert generation interacts with the tls-cipher algorithms.
#
#   note: in my tests, DHE-RSA-AES256-SHA is the one it negotiates if no value is set.
#
# auth SHA1
#
#   dkg: For HMAC digest to authenticate packets, we just want SHA256. OpenVPN lists
#   a number of “digest” with names like “RSA-SHA256”, but this are legacy and
#   should be avoided.
#
#   elijah: i am not so sure that the digest algo matters for 'auth' option, because
#   i think an attacker would have to forge the digest in real time, which is still far from
#   a possibility for SHA1. So, i am leaving the default for now (SHA1).
#
# cipher AES-128-CBC
#
#   dkg: For the choice of cipher, we need to select an algorithm and a
#   cipher mode. OpenVPN defaults to Blowfish, which is a fine algorithm — but
#   our control channel is already relying on AES not being broken; if the
#   control channel is cracked, then the key material for the tunnel is exposed,
#   and the choice of algorithm is moot. So it makes more sense to me to rely on
#   the same cipher here: AES128. As for the cipher mode, OFB seems cleaner to
#   me, but CBC is more well-tested, and the OpenVPN man page (at least as of
#   version 2.2.1) says “CBC is recommended and CFB and OFB should be considered
#   advanced modes.”
#
#   note: the default is BF-CBC (blowfish)
#

define site_openvpn::server_config(
  $port, $proto, $local, $server, $push,
  $management, $config, $tls_remote = undef) {

  $openvpn_configname = $name

  concat {
    "/etc/openvpn/${openvpn_configname}.conf":
      owner   => root,
      group   => root,
      mode    => 644,
      warn    => true,
      require => File['/etc/openvpn'],
      before  => Service['openvpn'],
      notify  => Exec['restart_openvpn'];
  }

  if $tls_remote != undef {
    openvpn::option {
      "tls-remote ${openvpn_configname}":
        key     => 'tls-remote',
        value   => $tls_remote,
        server  => $openvpn_configname;
    }
  }

  openvpn::option {
    "ca ${openvpn_configname}":
      key     => 'ca',
      value   => "${x509::variables::local_CAs}/${site_config::params::ca_bundle_name}.crt",
      server  => $openvpn_configname;
    "cert ${openvpn_configname}":
      key     => 'cert',
      value   => "${x509::variables::certs}/${site_config::params::cert_name}.crt",
        server  => $openvpn_configname;
    "key ${openvpn_configname}":
      key     => 'key',
      value   => "${x509::variables::keys}/${site_config::params::cert_name}.key",
      server  => $openvpn_configname;
    "dh ${openvpn_configname}":
      key     => 'dh',
      value   => '/etc/openvpn/keys/dh.pem',
      server  => $openvpn_configname;
    "tls-cipher ${openvpn_configname}":
      key     => 'tls-cipher',
      value   => $config['tls-cipher'],
      server  => $openvpn_configname;
    "auth ${openvpn_configname}":
      key     => 'auth',
      value   => $config['auth'],
      server  => $openvpn_configname;
    "cipher ${openvpn_configname}":
      key     => 'cipher',
      value   => $config['cipher'],
      server  => $openvpn_configname;
    "dev ${openvpn_configname}":
      key    => 'dev',
      value  => 'tun',
      server => $openvpn_configname;
    "duplicate-cn ${openvpn_configname}":
      key    => 'duplicate-cn',
      server => $openvpn_configname;
    "keepalive ${openvpn_configname}":
      key    => 'keepalive',
      value  => $config['keepalive'],
      server => $openvpn_configname;
    "local ${openvpn_configname}":
      key    => 'local',
      value  => $local,
      server => $openvpn_configname;
    "mute ${openvpn_configname}":
      key    => 'mute',
      value  => '5',
      server => $openvpn_configname;
    "mute-replay-warnings ${openvpn_configname}":
      key    => 'mute-replay-warnings',
      server => $openvpn_configname;
    "management ${openvpn_configname}":
      key    => 'management',
      value  => $management,
      server => $openvpn_configname;
    "proto ${openvpn_configname}":
      key    => 'proto',
      value  => $proto,
      server => $openvpn_configname;
    "push1 ${openvpn_configname}":
      key    => 'push',
      value  => $push,
      server => $openvpn_configname;
    "push2 ${openvpn_configname}":
      key    => 'push',
      value  => '"redirect-gateway def1"',
      server => $openvpn_configname;
    "script-security ${openvpn_configname}":
      key    => 'script-security',
      value  => '2',
      server => $openvpn_configname;
    "server ${openvpn_configname}":
      key    => 'server',
      value  => $server,
      server => $openvpn_configname;
    "status ${openvpn_configname}":
      key    => 'status',
      value  => '/var/run/openvpn-status 10',
      server => $openvpn_configname;
    "status-version ${openvpn_configname}":
      key    => 'status-version',
      value  => '3',
      server => $openvpn_configname;
    "topology ${openvpn_configname}":
      key    => 'topology',
      value  => 'subnet',
      server => $openvpn_configname;
    # no need for server-up.sh right now
    #"up $openvpn_configname":
    #    key    => 'up',
    #    value  => '/etc/openvpn/server-up.sh',
    #    server => $openvpn_configname;
    "verb ${openvpn_configname}":
      key    => 'verb',
      value  => '3',
      server => $openvpn_configname;
  }
}
