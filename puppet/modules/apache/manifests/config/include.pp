# deploy apache configuration file (includes for vhosts)
define apache::config::include(
    $ensure = present,
    $target = false,
    $source = 'absent',
    $content = 'absent',
    $destination = 'absent'
){
    apache::config::file { "${name}":
        ensure => $ensure,
        target => $target,
        type => 'include',
        source => $source,
        content => $content,
        destination => $destination,
    }
}
