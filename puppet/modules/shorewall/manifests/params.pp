define shorewall::params($value, $order='100'){
    shorewall::entry{"params-${order}-${name}":
        line => "${name}=${value}",
    }
}
