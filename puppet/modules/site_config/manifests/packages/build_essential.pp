#
# include this whenever you want to ensure build-essential package and related compilers are installed.
#
class site_config::packages::build_essential inherits ::site_config::packages {

  # NICKSERVER CODE NOTE: in order to support TLS, libssl-dev must be installed
  # before EventMachine gem is built/installed.
  Package[ 'gcc', 'make', 'g++', 'cpp', 'libssl-dev', 'libc6-dev' ] {
    ensure => present
  }

  case $::operatingsystemrelease {
    /^8.*/: {
      Package[ 'gcc-4.9','g++-4.9', 'cpp-4.9' ] {
        ensure => present
      }
    }

    /^7.*/: {
      Package[ 'gcc-4.7','g++-4.7', 'cpp-4.7' ] {
        ensure => present
      }
    }

    default:  { }
  }

}
