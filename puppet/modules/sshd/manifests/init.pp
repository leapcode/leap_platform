# manage an sshd installation
class sshd(
  $manage_nagios = false,
  $nagios_check_ssh_hostname = 'absent',
  $ports = [ 22 ],
  $shared_ip = 'no',
  $ensure_version = 'installed',
  $listen_address = [ '0.0.0.0', '::' ],
  $allowed_users = '',
  $allowed_groups = '',
  $use_pam = 'no',
  $permit_root_login = 'without-password',
  $password_authentication = 'no',
  $kerberos_authentication = 'no',
  $kerberos_orlocalpasswd = 'yes',
  $kerberos_ticketcleanup = 'yes',
  $gssapi_authentication = 'no',
  $gssapi_cleanupcredentials = 'yes',
  $tcp_forwarding = 'no',
  $x11_forwarding = 'no',
  $agent_forwarding = 'no',
  $challenge_response_authentication = 'no',
  $pubkey_authentication = 'yes',
  $rsa_authentication = 'no',
  $strict_modes = 'yes',
  $ignore_rhosts = 'yes',
  $rhosts_rsa_authentication = 'no',
  $hostbased_authentication = 'no',
  $permit_empty_passwords = 'no',
  $authorized_keys_file = $::osfamily ? {
    Debian => $::lsbmajdistrelease ? {
      6       => '%h/.ssh/authorized_keys',
      default => '%h/.ssh/authorized_keys %h/.ssh/authorized_keys2',
    },
    RedHat => $::operatingsystemmajrelease ? {
      5       => '%h/.ssh/authorized_keys',
      6       => '%h/.ssh/authorized_keys',
      default => '%h/.ssh/authorized_keys %h/.ssh/authorized_keys2',
    },
    OpenBSD => '%h/.ssh/authorized_keys',
    default => '%h/.ssh/authorized_keys %h/.ssh/authorized_keys2',
  },
  $hardened = 'no',
  $sftp_subsystem = '',
  $head_additional_options = '',
  $tail_additional_options = '',
  $print_motd = 'yes',
  $manage_shorewall = false,
  $shorewall_source = 'net',
  $sshkey_ipaddress = $::ipaddress,
  $manage_client = true,
  $hostkey_type = versioncmp($::ssh_version, '6.5') ? {
    /(^1|0)/ => [ 'rsa', 'ed25519' ],
    /-1/    => [ 'rsa', 'dsa' ]
  },
  $use_storedconfigs = true
) {

  validate_bool($manage_shorewall)
  validate_bool($manage_client)
  validate_array($listen_address)
  validate_array($ports)

  if $manage_client {
    class{'sshd::client':
      shared_ip        => $shared_ip,
      ensure_version   => $ensure_version,
      manage_shorewall => $manage_shorewall,
    }
  }

  case $::operatingsystem {
    gentoo: { include sshd::gentoo }
    redhat,centos: { include sshd::redhat }
    openbsd: { include sshd::openbsd }
    debian,ubuntu: { include sshd::debian }
    default: { include sshd::base }
  }

  if $manage_nagios {
    sshd::nagios{$ports:
      check_hostname => $nagios_check_ssh_hostname
    }
  }

  if $manage_shorewall {
    class{'shorewall::rules::ssh':
      ports  => $ports,
      source => $shorewall_source
    }
  }
}
