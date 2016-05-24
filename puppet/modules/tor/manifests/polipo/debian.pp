# manage polipo on debian
class tor::polipo::debian inherits tor::polipo::base {
  Service['polipo'] {
    hasstatus => false,
    pattern   => '/usr/bin/polipo',
  }
}
