# manage providers
define shorewall::providers(
  $provider   = $name,
  $number     = '',
  $mark       = '',
  $duplicate  = 'main',
  $interface  = '',
  $gateway    = '',
  $options    = '',
  $copy       = '',
  $order      = '100'
){
  shorewall::entry{"providers-${order}-${name}":
    line => "# ${name}\n${provider} ${number} ${mark} ${duplicate} ${interface} ${gateway} ${options} ${copy}"
  }
}
