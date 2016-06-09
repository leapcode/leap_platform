# wrapper to have some defaults.
define sshd::ssh_authorized_key(
    $ensure = 'present',
    $type = 'ssh-dss',
    $key = 'absent',
    $user = '',
    $target = undef,
    $options = 'absent',
    $override_builtin = undef
){

  if ($ensure=='present') and ($key=='absent') {
    fail("You have to set \$key for Sshd::Ssh_authorized_key[${name}]!")
  }

  $real_user = $user ? {
    false   => $name,
    ''      => $name,
    default => $user,
  }

  case $target {
    undef,'': {
      case $real_user {
        'root': { $real_target = '/root/.ssh/authorized_keys' }
        default: { $real_target = "/home/${real_user}/.ssh/authorized_keys" }
      }
    }
    default: {
      $real_target = $target
    }
  }

  # The ssh_authorized_key built-in function (in 2.7.23 at least)
  # will not write an authorized_keys file for a mortal user to
  # a directory they don't have write permission to, puppet attempts to
  # create the file as the user specified with the user parameter and fails.
  # Since ssh will refuse to use authorized_keys files not owned by the
  # user, or in files/directories that allow other users to write, this
  # behavior is deliberate in order to prevent typical non-working
  # configurations. However, it also prevents the case of puppet, running
  # as root, writing a file owned by a mortal user to a common
  # authorized_keys directory such as one might specify in sshd_config with
  # something like
  #  'AuthorizedKeysFile /etc/ssh/authorized_keys/%u'
  # So we provide a way to override the built-in and instead just install
  # via a file resource. There is no additional security risk here, it's
  # nothing a user can't already do by writing their own file resources,
  # we still depend on the filesystem permissions to keep things safe.
  if $override_builtin {
    $header = "# HEADER: This file is managed by Puppet.\n"

    if $options == 'absent' {
      info("not setting any option for ssh_authorized_key: ${name}")
      $content = "${header}${type} ${key}\n"
    } else {
      $content = "${header}${options} ${type} ${key}\n"
    }

    file { $real_target:
      ensure  => $ensure,
      content => $content,
      owner   => $real_user,
      mode    => '0600',
    }

  } else {

    if $options == 'absent' {
      info("not setting any option for ssh_authorized_key: ${name}")
    } else {
      $real_options = $options
    }

    ssh_authorized_key{$name:
      ensure  => $ensure,
      type    => $type,
      key     => $key,
      user    => $real_user,
      target  => $real_target,
      options => $real_options,
    }
  }

}
