define shorewall::rfc1918(
    $action = 'logdrop',
    $order='100'
){
    shorewall::entry{"rfc1918-${order}-${name}":
        line => "${name} ${action}"
    }   
}
