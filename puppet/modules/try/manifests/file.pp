#
# like built-in type "file", but gets gracefully ignored if the target does not exist or is undefined.
#
# /bin/true and /usr/bin/test are hardcoded to their paths in debian.
#

define try::file (
  $ensure = undef,
  $target = undef,
  $restore = true) {

  if $target != undef {
    exec { "check_${name}":
      command => "/bin/true",
      onlyif => "/usr/bin/test -e '${target}'",
      loglevel => info;
    }
    file { "$name":
      ensure => $ensure,
      target => $target,
      require => Exec["check_${name}"],
      loglevel => info;
    }
  }

  #
  # if the target does not exist (or is undef), and the file happens to be in a git repo,
  # then restore the file to its original state.
  #
  if $target == undef or $restore {
    $file_basename = basename($name)
    $file_dirname  = dirname($name)
    $command = "git rev-parse && unlink '${name}'; git checkout -- '${file_basename}' && chown --reference='${file_dirname}' '${name}'; true"
    debug($command)

    if $target == undef {
      exec { "restore_${name}":
        command => $command,
        cwd => $file_dirname,
        loglevel => info;
      }
    } else {
      exec { "restore_${name}":
        unless => "/usr/bin/test -e '${target}'",
        command => $command,
        cwd => $file_dirname,
        loglevel => info;
      }
    }
  }
}
