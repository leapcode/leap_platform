# debian has some issues with absent
# init scripts.
# It's a bug in debian's provider that should be fixed in puppet, but in the
# meantime we need this hack.
#
# see: https://projects.puppetlabs.com/issues/9381
class postfix::disable::debian inherits postfix::disable::base {
  Service['postfix']{
    hasstatus => false,
  }
}
