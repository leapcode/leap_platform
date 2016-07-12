# manifests/webdav.pp

class apache::webdav {
    file{'/var/www/webdavlock':
        ensure => directory,
        owner => apache, group => 0, mode => 0700;
    }
}
