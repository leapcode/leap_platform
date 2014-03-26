#
# include this whenever you want to ensure build-essential package and related compilers are installed.
#
class site_config::packages::build_essential {
  if $install_build_essential == undef {
    $install_build_essential = true
  }
}