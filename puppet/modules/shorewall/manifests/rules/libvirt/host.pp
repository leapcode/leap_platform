class shorewall::rules::libvirt::host (
  $vmz           = 'vmz',
  $masq_iface    = 'eth0',
  $debproxy_port = 8000,
  $accept_dhcp   = true,
  $vmz_iface     = 'virbr0',
  ) {

  define shorewall::rule::accept::from_vmz (
    $proto           = '-',
    $destinationport = '-',
    $action          = 'ACCEPT'
    ) {
      shorewall::rule { $name:
        source          => $shorewall::rules::libvirt::host::vmz,
        destination     => '$FW',
        order           => 300,
        proto           => $proto,
        destinationport => $destinationport,
        action          => $action;
      }
    }

  shorewall::policy {
    'fw-to-vmz':
      sourcezone              =>      '$FW',
      destinationzone         =>      $vmz,
      policy                  =>      'ACCEPT',
      order                   =>      110;
    'vmz-to-net':
      sourcezone              =>      $vmz,
      destinationzone         =>      'net',
      policy                  =>      'ACCEPT',
      order                   =>      200;
    'vmz-to-all':
      sourcezone              =>      $vmz,
      destinationzone         =>      'all',
      policy                  =>      'DROP',
      shloglevel              =>      'info',
      order                   =>      800;
  }

  shorewall::rule::accept::from_vmz {
    'accept_dns_from_vmz':
      action          => 'DNS(ACCEPT)';
    'accept_tftp_from_vmz':
      action          => 'TFTP(ACCEPT)';
    'accept_puppet_from_vmz':
      proto           => 'tcp',
      destinationport => '8140',
      action          => 'ACCEPT';
  }

  if $accept_dhcp {
    shorewall::mangle { 'CHECKSUM:T':
      source          => '-',
      destination     => $vmz_iface,
      proto           => 'udp',
      destinationport => '68';
    }
  }

  if $debproxy_port {
    shorewall::rule::accept::from_vmz { 'accept_debproxy_from_vmz':
      proto           => 'tcp',
      destinationport => $debproxy_port,
      action          => 'ACCEPT';
    }
  }

  if $masq_iface {
    shorewall::masq {
      "masq-${masq_iface}":
        interface => $masq_iface,
        source    => '10.0.0.0/8,169.254.0.0/16,172.16.0.0/12,192.168.0.0/16';
    }
  }

}
