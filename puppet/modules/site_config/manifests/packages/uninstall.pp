#
# Uninstall build-essential and compilers, unless they have been explicitly installed elsewhere.
#
class site_config::packages::uninstall {
  tag 'leap_base'

  # generally, dev packages are needed for installing ruby gems with native extensions.
  # (nickserver, webapp, etc)

  if !defined(Package['build-essential']) {
    package {
      ['build-essential', 'g++', 'g++-4.7', 'gcc', 'gcc-4.6', 'gcc-4.7', 'cpp', 'cpp-4.6', 'cpp-4.7', 'libc6-dev']:
        ensure => purged
    }
  }
}