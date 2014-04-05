#
# include this whenever you want to ensure build-essential package and related compilers are installed.
#
class site_config::packages::build_essential {
  if !defined(Package['build-essential']) {
    package {
      ['build-essential', 'g++', 'g++-4.7', 'gcc', 'gcc-4.6', 'gcc-4.7', 'cpp', 'cpp-4.6', 'cpp-4.7', 'libc6-dev']:
        ensure => present
    }
  }
}