define shorewall::policy(
    $sourcezone,
    $destinationzone,
    $policy, $shloglevel = '-',
    $limitburst = '-',
    $order
){
    shorewall::entry{"policy-${order}-${name}":
        line => "# ${name}\n${sourcezone} ${destinationzone} ${policy} ${shloglevel} ${limitburst}",
    }
}

