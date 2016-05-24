class shorewall::ubuntu::karmic inherits shorewall::debian {
  Package['shorewall']{
    name => 'shorewall-shell',
  }
}
