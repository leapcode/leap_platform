define shorewall::proxyarp(
    $interface,
    $external,
    $haveroute = yes,
    $persistent = no,
    $order='100'
    ){
    shorewall::entry{"proxyarp-${order}-${name}":
        line => "# ${name}\n${name} ${interface} ${external} ${haveroute} ${persistent}"
    }
}
