# manifests/client.pp

class sshd::client(
  $shared_ip = 'no',
  $ensure_version = 'installed',
  $manage_shorewall = false
) {

  case $::operatingsystem {
    debian,ubuntu: { include sshd::client::debian }
    default: {
      case $::kernel {
        linux: { include sshd::client::linux }
        default: { include sshd::client::base }
      }
    }
  }

  if $manage_shorewall{
    include shorewall::rules::out::ssh
  }
}
