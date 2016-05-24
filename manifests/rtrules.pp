define shorewall::rtrules(
    $source = '-',
    $destination = '-',
    $provider,
    $priority = '10000',
    $mark,
){
    shorewall::entry { "rtrules-${mark}-${name}":
        line => "# ${name}\n${source} ${destination} ${provider} ${priority} ${mark}",
    }
}
