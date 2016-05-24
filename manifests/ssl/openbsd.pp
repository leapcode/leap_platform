class apache::ssl::openbsd inherits apache::openbsd {
    include apache::ssl::base

    File_line['enable_apache_on_boot']{
        ensure => 'absent',
    }
    file_line{'enable_apachessl_on_boot':
        path => '/etc/rc.conf.local',
        line => 'httpd flags="-DSSL"',
    }

    File['/opt/bin/restart_apache.sh']{
        source => "puppet:///modules/apache/scripts/OpenBSD/bin/restart_apache_ssl.sh",
    }
    Service['apache']{
        start => 'apachectl startssl',
    }
}
