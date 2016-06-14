# See http://shorewall.net/shorewall_extension_scripts.htm
define shorewall::extension_script(
  $script
) {
  case $name {
    'init', 'initdone', 'start', 'started', 'stop', 'stopped', 'clear', 'refresh', 'continue', 'maclog': {
      file { "/etc/shorewall/puppet/${name}":
        content => "${script}\n",
        notify  => Exec['shorewall_check'];
      }
    }
    default: {
      err("${name}: unknown shorewall extension script")
    }
  }
}
