define shorewall::tunnel(
    $tunnel_type,
    $zone,
    $gateway = '0.0.0.0/0',
    $gateway_zones = '',
    $order = '1'
) {
    shorewall::entry { "tunnel-${order}-${name}":
        line => "# ${name}\n${tunnel_type} ${zone} ${gateway} ${gateway_zones}",
    }
}
