class site_config::ruby {
  Class[Ruby] -> Class[rubygems] -> Class[bundler::install]
  class { '::ruby': ruby_version => '1.9.3' }
  class { 'bundler::install': install_method => 'package' }
  include rubygems
}


#
# Ruby settings common to all servers
#
# Why this way? So that other classes can do 'include site_ruby' without creating redeclaration errors.
# See https://puppetlabs.com/blog/modeling-class-composition-with-parameterized-classes/
#
