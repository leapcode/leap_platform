define shorewall::tcdevices(
    $in_bandwidth,
    $out_bandwidth,
    $options = '',
    $redirected_interfaces = '',
    $order = '100'
){
    shorewall::entry { "tcdevices-${order}-${name}":
        line => "${name} ${in_bandwidth} ${out_bandwidth} ${options} ${redirected_interfaces}",
    }
}
