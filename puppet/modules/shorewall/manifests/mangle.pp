define shorewall::mangle(
  $source,
  $destination,
  $proto           = '-',
  $destinationport = '-',
  $sourceport      = '-',
  $user            = '-',
  $test            = '-',
  $length          = '-',
  $tos             = '-',
  $connbytes       = '-',
  $helper          = '-',
  $headers         = '-',
  $order           = '100'
){
  shorewall::entry{"mangle-${order}-${name}":
    line => "${name} ${source} ${destination} ${proto} ${destinationport} ${sourceport} ${user} ${test} ${length} ${tos} ${connbytes} ${helper} ${headers}"
  }
}
