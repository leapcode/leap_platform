define shorewall::nat(
    $interface,
    $internal,
    $all = 'no',
    $local = 'yes',
    $order='100'
){
    shorewall::entry{"nat-${order}-${name}":
        line => "${name} ${interface} ${internal} ${all} ${local}"
    }           
}
