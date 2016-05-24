# manage sftponly group and apache
# user for access
class apache::sftponly::centos {
  require user::groups::sftponly
  user::groups::manage_user{'apache':
    group   => 'sftponly',
    require => Package['apache'],
    notify  => Service['apache'],
  }
}
