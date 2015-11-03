#
# include this whenever you want to ensure build-essential package and related compilers are installed.
#
class site_config::packages::build_essential {
  if !defined(Package['build-essential']) {
    package {
      ['build-essential', 'cpp']:
        ensure => present
    }
  }
}
