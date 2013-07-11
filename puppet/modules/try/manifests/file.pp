#
# Works like the built-in type "file", but gets gracefully ignored if the target/source does not exist or is undefined.
#
# Also, if the source or target doesn't exist, and the destination is a git repo, then the file is restored from git.
#
# /bin/true and /usr/bin/test are hardcoded to their paths in debian.
#
# known limitations:
# * restore does not work for directories
#
define try::file (
  $ensure = undef,
  $target = undef,
  $source = undef,
  $owner = undef,
  $group = undef,
  $recurse = undef,
  $purge = undef,
  $force = undef,
  $mode = undef,
  $restore = true) {

  if $target {
    $target_or_source = $target
  } else {
    $target_or_source = $source
  }

  if $target_or_source != undef {
    exec { "check_${name}":
      command => "/bin/true",
      onlyif => "/usr/bin/test -e '${target_or_source}'",
      loglevel => info;
    }
    file { "$name":
      ensure => $ensure,
      target => $target,
      source => $source,
      owner => $owner,
      group => $group,
      recurse => $recurse,
      purge => $purge,
      force => $force,
      mode => $mode,
      require => $require ? {
        undef   => Exec["check_${name}"],
        default => [ $require, Exec["check_${name}"] ]
      },
      loglevel => info;
    }
  }

  #
  # if the target/source does not exist (or is undef), and the file happens to be in a git repo,
  # then restore the file to its original state.
  #
  if ($target_or_source == undef) or $restore {
    $file_basename = basename($name)
    $file_dirname  = dirname($name)
    $command = "git rev-parse && unlink '${name}'; git checkout -- '${file_basename}' && chown --reference='${file_dirname}' '${name}'; true"
    debug($command)

    if $target == undef {
      exec { "restore_${name}":
        command => $command,
        cwd => $file_dirname,
        require => $require ? {
          undef   => undef,
          default => [ $require ]
        },
        loglevel => info;
      }
    } else {
      exec { "restore_${name}":
        unless => "/usr/bin/test -e '${target_or_source}'",
        command => $command,
        cwd => $file_dirname,
        require => $require ? {
          undef   => undef,
          default => [ $require ]
        },
        loglevel => info;
      }
    }
  }
}
