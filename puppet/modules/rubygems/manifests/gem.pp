# Installs gems that are slightly broken
# As a name it expects the name of the gem.
# If you want to want to install a certain version
# you have to append the version to the gem name:
#
#    install a version of mime-types:
#       rubygems::gem{'mime-types': }
#
#    install version 0.0.4 of ruby-net-ldap:
#       rubygems::gem{'ruby-net-ldap-0.0.4': }
#
#    uninstall polygot gem (until no such gem is anymore installed):
#       rubygems::gem{'polygot': ensure => absent }
#
#    uninstall ruby-net-ldap version 0.0.3
#       rubygems::gem{'ruby-net-ldap-0.0.3': ensure => absent }
#
# You can also set your own buildlfags, which will then install
# the gem in question by the gem command.
#
# You can also enforce to use the gem command to manage the gem
# by setting provider to `exec`.
#
define rubygems::gem(
  $ensure = 'present',
  $source = 'absent',
  $provider = 'default',
  $buildflags = 'absent',
  $requiresgcc = false
) {
  require ::rubygems
  if $requiresgcc or ($buildflags != 'absent') {
    require ::gcc
  }

  if $name =~ /\-(\d|\.)+$/ {
    $real_name = regsubst($name,'^(.*)-(\d|\.)+$','\1')
    $gem_version = regsubst($name,'^(.*)-(\d+(\d|\.)+)$','\2')
  } else {
    $real_name = $name
  }

  if $source != 'absent' {
    if $ensure != 'absent' {
      require rubygems::gem::cachedir
      exec{"get-gem-$name":
        command => "/usr/bin/wget -O ${rubygems::gem::cachedir::dir}/$name.gem $source",
        creates => "${rubygems::gem::cachedir::dir}/$name.gem",
      }
    } else {
      file{"${rubygems::gem::cachedir::dir}/$name.gem":
        ensure => 'absent';
      }
    }
  }

  if ($buildflags != 'absent') or ($provider == 'exec') {
    if $gem_version {
        $gem_version_str = "-v ${gem_version}"
        $gem_version_check_str = $gem_version
    } else {
        $gem_version_check_str = '.*'
    }

    if $ensure == 'present' {
        $gem_cmd = 'install'
    } else {
        $gem_cmd = 'uninstall -x'
    }

    if $buildflags != 'absent' {
      $buildflags_str = "-- --build-flags ${buildflags}"
    } else {
      $buildflags_str = ''
    }

    exec{"manage_gem_${name}":
        command => "gem ${gem_cmd} ${real_name} ${gem_version_str} ${buildflags_str}",
    }

    $gem_cmd_check_str = "gem list | egrep -q '^${real_name} \\(${gem_version_check_str}\\)\$'"
    if $ensure == 'present' {
        Exec["manage_gem_${name}"]{
           unless => $gem_cmd_check_str
        }
    } else {
        Exec["manage_gem_${name}"]{
           onlyif => $gem_cmd_check_str
        }
    }
  } else {
    package{"$real_name":
      ensure => $ensure ? {
        'absent' => $ensure,
        default => $gem_version ? {
          undef => $ensure,
          default => $gem_version
        }
      },
      provider => gem,
    }
    if $source != 'absent' {
      Package["$name"]{
        source => "${rubygems::gem::cachedir::dir}/$name.gem"
      }
    }
  }
}
