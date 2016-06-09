define shorewall::managed_file () {
  concat{ "/etc/shorewall/puppet/${name}":
    notify => Service['shorewall'],
    require => File['/etc/shorewall/puppet'],
    owner => root, group => 0, mode => 0600;
  }
  concat::fragment {
    "${name}-header":
      source => "puppet:///modules/shorewall/boilerplate/${name}.header",
      target => "/etc/shorewall/puppet/${name}",
      order => '000';
    "${name}-footer":
      source => "puppet:///modules/shorewall/boilerplate/${name}.footer",
      target => "/etc/shorewall/puppet/${name}",
      order => '999';
  }
}
