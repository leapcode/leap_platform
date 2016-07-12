class apache::sftponly {
  case $::operatingsystem {
    centos: { include apache::sftponly::centos }
  }
}
