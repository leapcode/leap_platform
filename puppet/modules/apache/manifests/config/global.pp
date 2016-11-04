# deploy apache configuration file (global)
# wrapper for apache::config::file
define apache::config::global(
    $ensure = present,
    $target = false,
    $source = 'absent',
    $content = 'absent',
    $destination = 'absent'
){
    apache::config::file { "${name}":
        ensure => $ensure,
        target => $target,
        type => 'global',
        source => $source,
        content => $content,
        destination => $destination,
    }
}
