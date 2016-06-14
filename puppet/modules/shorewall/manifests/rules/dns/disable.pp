# disable dns acccess
class shorewall::rules::dns::disable inherits shorewall::rules::dns {
  Shorewall::Rules::Dns_rules['net']{
    action  => 'DROP',
  }
}
