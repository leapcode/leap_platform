# Class: ruby
#
# This class installs Ruby
#
# Parameters:
#
# version: (default installed)
# Set the version of Ruby to install
#
# Sample Usage:
#
# For a standard install using the latest ruby, simply do:
#
# class { 'ruby': }
#
# On Debian this is equivilant to
# $ apt-get install ruby
#
# To install a specific version of ruby, simply do:
#
# class { 'ruby':
#    ruby_version => '1.8.7',
# }
#
# Supported versions: 1.8, 1.8.7, 1.9, 1.9.1, 1.9.3
#
# To install the development files, you can do:
#
# class { 'ruby': install_dev => true }

class ruby (
  $ruby_version      = '',
  $version           = 'installed',
  $install_dev       = false
)
{

  case $::operatingsystem {
    'redhat', 'suse': {
      $ruby_package='ruby'
      $ruby_dev='ruby-devel'
    }
    'debian', 'ubuntu': {
      case $ruby_version {
        '1.8', '1.8.7': {
          $ruby_package = 'ruby1.8'
          $ruby_dev = [ 'ruby1.8-dev', 'rake' ]
        }
        '1.9.1': {
          $ruby_package = 'ruby1.9.1'
          $ruby_dev = [ 'ruby1.9.1-dev', 'rake' ]
        }
        '1.9', '1.9.3': {
          $ruby_package = 'ruby1.9.3'
          $ruby_dev = [ 'ruby-dev', 'rake' ]
        }
        default: {
          $ruby_package = 'ruby'
          $ruby_dev = [ 'ruby-dev', 'rake' ]
        }
      }
    }
  }

  package{ $ruby_package:
    ensure => $version,
  }

  if $install_dev {
    ensure_packages($ruby_dev)
  }
}
