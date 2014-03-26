#
# this should be included last to allow other modules to set $::install_build_packages
#
class site_config::packages::uninstall {

  if $site_config::packages::build_essential::install_essential == true {
    $dev_packages_ensure = present
  } else {
    $dev_packages_ensure = absent
  }

  # generally, dev packages are needed for installing ruby gems with native extensions.
  # (nickserver, webapp, etc)

  package { [ 'build-essential', 'g++', 'g++-4.7', 'gcc',
              'gcc-4.6', 'gcc-4.7', 'cpp', 'cpp-4.6', 'cpp-4.7', 'libc6-dev' ]:
    ensure => $dev_packages_ensure
  }

}