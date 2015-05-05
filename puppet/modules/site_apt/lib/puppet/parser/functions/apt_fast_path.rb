module Puppet::Parser::Functions
  newfunction(:apt_fast_path, :type => :rvalue, :doc => 'path of apt-fast') do |arguments|
    APT_FAST_PATH
  end
end

