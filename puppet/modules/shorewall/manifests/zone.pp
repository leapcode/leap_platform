define shorewall::zone(
    $type,
    $options = '-',
    $in = '-',
    $out = '-',
    $parent = '-',
    $order = 100
){
    $real_name = $parent ? { '-' => $name, default => "${name}:${parent}" }
    shorewall::entry { "zones-${order}-${name}":
        line => "${real_name} ${type} ${options} ${in} ${out}"
    }
}

