class apache::ssl::centos inherits apache::ssl::base {
    package { 'mod_ssl':
        name => 'mod_ssl',
        ensure => present,
        require => Package[apache],
    }
    ::apache::config::global{ 'ssl.conf': }

    apache::config::global{'00-listen-ssl.conf':
      ensure => absent,
    }
}
