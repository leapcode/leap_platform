# Class bundler::install
#
# Installs bundler Ruby gem manager
#
# == Parameters
#
#   [*install_method*]
#     How to install bundler, 'rvm' is the default
#   [*ruby_version*]
#     Ruby version that bundler will use.
#
# == Examples
#
#
# == Requires:
#
#   If use_rvm = 'true':
#   include rvm
#
class bundler::install (
  $ruby_version    = undef,
  $ensure          = 'present',
  $install_method  = 'rvm',
  $use_rvm         = '',
  ) inherits bundler::params {

  # deprecation warning
  if $use_rvm != '' {
    warning('$use_rvm is deprecated, please use $install_method instead')
  }

  if ( $install_method == undef ) or ( $install_method == 'package' ) {
    $provider_method = undef
  }
  else {
    # backwards compatibility
    if $use_rvm == false {
      $provider_method = gem
    }
    else {
      $provider_method = $bundler::params::install_method
    }
  }

  if $provider_method == 'rvm' {
    if $ruby_version == undef {
      fail('When using rvm, you must pass a ruby_version')
    }
    else {
      #Install bundler with correct RVM
      rvm_gem { 'bundler':
        ensure       => $ensure,
        ruby_version => $ruby_version,
      }
    }
  }
  else {
    package { 'bundler':
      ensure   => $ensure,
      provider => $provider_method,
    }
  }

}
