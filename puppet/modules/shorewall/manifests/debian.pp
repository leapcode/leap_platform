# debian specific things
class shorewall::debian inherits shorewall::base {
  file{'/etc/default/shorewall':
    content => template('shorewall/debian_default.erb'),
    require => Package['shorewall'],
    notify  => Exec['shorewall_check'],
    owner   => 'root',
    group   => 'root',
    mode    => '0644';
  }
}
