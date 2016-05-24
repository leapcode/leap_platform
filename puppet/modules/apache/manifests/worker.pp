class apache::worker inherits apache {
  case $::operatingsystem {
    centos: { include ::apache::centos::worker }
  }
}
