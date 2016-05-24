class ruby::mysql {
  include ruby
  package{'ruby-mysql':
    ensure => present,
    require => Package['ruby'],
  }
}
