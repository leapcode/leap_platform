# install/remove apache module on debian/ubuntu systems
define apache::debian::module(
  $ensure = present,
  $package_name = 'absent',
  $conf_source = '',
  $conf_content = '',
){
  $modules_dir = "${apache::debian::config_dir}/mods"

  if ($package_name != 'absent') {
    package { $package_name:
      ensure  => $ensure,
      notify  => Service['apache'],
      require => [ File['modules_dir'], Package['apache'] ],
    }
    $required_packages = [ 'apache', $package_name ]
  }
  else {
    $required_packages = [ 'apache' ]
  }

  file {
    "${modules_dir}-enabled/${name}.load":
      ensure  => "../mods-available/${name}.load",
      notify  => Service['apache'],
      require => [ File['modules_dir'], Package[$required_packages] ];
    "${modules_dir}-enabled/${name}.conf":
      ensure  => "../mods-available/${name}.conf",
      notify  => Service['apache'],
      require => [ File['modules_dir'], Package[$required_packages] ];
    "${modules_dir}-available/${name}.conf":
      ensure  => file,
      notify  => Service['apache'],
      require => [ File['modules_dir'], Package[$required_packages] ];
  }

  if $conf_content != '' {
    File["${modules_dir}-available/${name}.conf"] {
      content => $conf_content,
    }
  }
  elsif $conf_source != '' {
    File["${modules_dir}-available/${name}.conf"] {
      source => $conf_source,
    }
  }

}
