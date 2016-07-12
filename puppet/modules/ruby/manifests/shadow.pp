class ruby::shadow {
  case $::operatingsystem {
    debian,ubuntu: { include ruby::shadow::debian }
    default: { include ruby::shadow::base }
  }
}
