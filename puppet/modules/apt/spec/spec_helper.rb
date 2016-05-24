# https://puppetlabs.com/blog/testing-modules-in-the-puppet-forge
require 'rspec-puppet'
require 'mocha/api'

RSpec.configure do |c|

  c.module_path = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
  c.color = true

  #Puppet.features.stubs(:root? => true)

end
