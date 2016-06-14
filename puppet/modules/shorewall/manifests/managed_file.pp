# manage a certain file
define shorewall::managed_file() {
  concat{ "/etc/shorewall/puppet/${name}":
    notify  => Exec['shorewall_check'],
    require => File['/etc/shorewall/puppet'],
    owner   => 'root',
    group   => 'root',
    mode    => '0600';
  }
  concat::fragment {
    "${name}-header":
      source => "puppet:///modules/shorewall/boilerplate/${name}.header",
      target => "/etc/shorewall/puppet/${name}",
      order  => '000';
    "${name}-footer":
      source => "puppet:///modules/shorewall/boilerplate/${name}.footer",
      target => "/etc/shorewall/puppet/${name}",
      order  => '999';
  }
}
