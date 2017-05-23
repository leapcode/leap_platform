# Gets included on vagrant nodes
class site_config::vagrant {

  include site_shorewall::defaults
  # eth0 on vagrant nodes is the uplink
  shorewall::interface { 'eth0':
    zone    => 'net',
    options => 'tcpflags,blacklist,nosmurfs';
  }

}
