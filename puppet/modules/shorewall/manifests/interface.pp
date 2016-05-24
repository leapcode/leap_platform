define shorewall::interface(
    $zone,
    $broadcast = 'detect',
    $options = 'tcpflags,blacklist,routefilter,nosmurfs,logmartians',
    $add_options = '',
    $rfc1918 = false,
    $dhcp = false,
    $order = 100
){
    $added_opts = $add_options ? {
        ''      => '',
        default => ",${add_options}",
    }

    $dhcp_opt = $dhcp ? {
        false   => '',
        default => ',dhcp',
    }

    $rfc1918_opt = $rfc1918 ? {
        false   => ',norfc1918',
        default => '',
    }

    shorewall::entry { "interfaces-${order}-${name}":
        line => "${zone} ${name} ${broadcast} ${options}${dhcp_opt}${rfc1918_opt}${added_opts}",
    }
}

