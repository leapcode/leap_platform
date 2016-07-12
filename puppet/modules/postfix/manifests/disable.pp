# remove postfix
class postfix::disable {
  case $::operatingsystem {
    debian: { include postfix::disable::debian }
    default: { include postfix::disable::base }
  }
}
