/*
== Definition: postfix::virtual

Manages content of the /etc/postfix/virtual map.

Parameters:
- *name*: name of address postfix will lookup. See virtual(8).
- *destination*: where the emails will be delivered to. See virtual(8).
- *ensure*: present/absent, defaults to present.

Requires:
- Class["postfix"]
- Postfix::Hash["/etc/postfix/virtual"]
- Postfix::Config["virtual_alias_maps"]
- file_line (from module stdlib)

Example usage:

  node "toto.example.com" {

    class { 'postfix': }

    postfix::hash { "/etc/postfix/virtual":
      ensure => present,
    }
    postfix::config { "virtual_alias_maps":
      value => "hash:/etc/postfix/virtual"
    }
    postfix::virtual { "user@example.com":
      ensure      => present,
      destination => "root",
    }
  }

*/
define postfix::virtual ($ensure="present", $destination) {
  file_line {"${name} ${destination}":
    ensure => $ensure,
    path   => "/etc/postfix/virtual",
    line   => "${name} ${destination}",
    notify => Exec["generate /etc/postfix/virtual.db"],
    require => Package["postfix"],
  }
}
