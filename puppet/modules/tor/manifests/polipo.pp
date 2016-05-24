# manage the polipo proxy service
class tor::polipo {
  include ::tor

  case $::operatingsystem {
    'debian': { include tor::polipo::debian }
    default:  { include tor::polipo::base   }
  }
}
