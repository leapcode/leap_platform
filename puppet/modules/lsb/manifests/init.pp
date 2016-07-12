class lsb {
  case $::operatingsystem {
    debian,ubuntu: { include lsb::debian }
    centos: { include lsb::centos }
  }
}
