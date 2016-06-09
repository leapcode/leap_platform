define shorewall::entry(
    $ensure = present,
    $line
){
  $parts = split($name,'-')
  concat::fragment{$name:
    ensure => $ensure,
    content => "${line}\n",
    order => $parts[1],
    target => "/etc/shorewall/puppet/${parts[0]}",
  }
}
