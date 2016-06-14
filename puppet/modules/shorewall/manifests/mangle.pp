define shorewall::mangle(
  $source,
  $destination,
  $action          = $name,
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
    line => "${action} ${source} ${destination} ${proto} ${destinationport} ${sourceport} ${user} ${test} ${length} ${tos} ${connbytes} ${helper} ${headers}"
  }
}
