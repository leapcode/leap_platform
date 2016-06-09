class apache::mod_macro {
    package{'mod_macro':
        ensure => installed,
        require => Package['apache'],
        notify => Service['apache'],
    }
}
