# Gets included on vagrant nodes
class site_config::vagrant {

  include site_shorewall::defaults

  if ( $::site_config::params::interface == 'eth1' ) {
    # Don't block eth0 even if eth1 is configured, because
    # it's vagrant's main interface to access the box
    shorewall::interface { 'eth0':
      zone    => 'net',
      options => 'tcpflags,blacklist,nosmurfs';
    }
  }

}
