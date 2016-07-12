class apache::defaultdavdbdir {
    file {
        '/var/www/dav_db_dir' :
            ensure => directory,
            require => Package['apache'],
            owner => root,
            group => 0,
            mode => 0755 ;
    }
    if $::selinux != 'false' {
        selinux::fcontext {
            ['/var/www/dav_db_dir/.+(/.*)?'] :
                setype => 'httpd_var_lib_t',
                before => File['/var/www/dav_db_dir'] ;
        }
    }
}
