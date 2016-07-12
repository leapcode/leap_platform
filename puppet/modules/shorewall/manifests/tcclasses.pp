define shorewall::tcclasses(
    $interface,
    $rate,
    $ceil,
    $priority,
    $options = '',
    $order = '1'
){
    shorewall::entry { "tcclasses-${order}-${name}":
        line => "# ${name}\n${interface} ${order} ${rate} ${ceil} ${priority} ${options}",
    }
}
