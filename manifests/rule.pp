# mark is new in 3.4.4
define shorewall::rule(
    $ensure = present,
    $action,
    $source,
    $destination,
    $proto = '-',
    $destinationport = '-',
    $sourceport = '-',
    $originaldest = '-',
    $ratelimit = '-',
    $user = '-',
    $mark = '',
    $order
){
  shorewall::entry{"rules-${order}-${name}":
    ensure => $ensure,
    line => "# ${name}\n${action} ${source} ${destination} ${proto} ${destinationport} ${sourceport} ${originaldest} ${ratelimit} ${user} ${mark}",
  }
}
