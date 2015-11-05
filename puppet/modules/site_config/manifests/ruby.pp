# install ruby, rubygems and bundler
# configure ruby settings common to all servers
class site_config::ruby {
  Class[Ruby] -> Class[rubygems] -> Class[bundler::install]
  class { '::ruby': }
  class { 'bundler::install': install_method => 'package' }
  include rubygems
}
