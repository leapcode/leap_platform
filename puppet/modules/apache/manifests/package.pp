# deploy apache as package
class apache::package inherits apache::base {
    package { 'apache':
        name => 'apache',
        ensure => present,
    }
    File['vhosts_dir']{
        require => Package[apache],
    }
    File['config_dir']{
        require => Package[apache],
    }
    Service['apache']{
        require => Package[apache],
    }
    File['default_apache_index']{
        require => Package[apache],
    }
    File['modules_dir']{
        require => Package[apache],
    }
    File['include_dir']{
        require => Package[apache],
    }
    File['web_dir']{
        require => Package[apache],
    }
    File['htpasswd_dir']{
        require => Package[apache],
    }
}

