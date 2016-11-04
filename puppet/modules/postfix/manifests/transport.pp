/*
== Definition: postfix::transport

Manages content of the /etc/postfix/transport map.

Parameters:
- *name*: name of address postfix will lookup. See transport(5).
- *destination*: where the emails will be delivered to. See transport(5).
- *ensure*: present/absent, defaults to present.

Requires:
- Class["postfix"]
- Postfix::Hash["/etc/postfix/transport"]
- Postfix::Config["transport_maps"]
- file_line (from module stdlib)

Example usage:

  node "toto.example.com" {

    class { 'postfix': }

    postfix::hash { "/etc/postfix/transport":
      ensure => present,
    }
    postfix::config { "transport_maps":
      value => "hash:/etc/postfix/transport"
    }
    postfix::transport { "mailman.example.com":
      ensure      => present,
      destination => "mailman",
    }
  }

*/
define postfix::transport ($ensure="present", $destination) {
  file_line {"${name} ${destination}":
    ensure => $ensure,
    path   => "/etc/postfix/transport",
    line   => "${name} ${destination}",
    notify => Exec["generate /etc/postfix/transport.db"],
    require => Package["postfix"],
  }
}
