define shorewall::rule_section(
    $order
){
    shorewall::entry{"rules-${order}-${name}":
        line => "SECTION ${name}",
    }       
}
