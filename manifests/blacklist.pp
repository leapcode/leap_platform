define shorewall::blacklist(
    $proto = '-',
    $port = '-',
    $order='100'
){
    shorewall::entry{"blacklist-${order}-${name}":
        line => "${name} ${proto} ${port}",
    }           
}
