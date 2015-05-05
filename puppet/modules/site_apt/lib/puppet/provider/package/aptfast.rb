#
# Use apt-fast instead of apt-get, when available.
#
# This package provider will change the default for debian and ubuntu.
# If we don't want this to be the case all the time, we can comment
# out 'defaultfor' line and add this to site.pp:
#
#   Package { provider => "aptfast" }
#

APT_FAST_PATH = '/usr/local/bin/apt-fast'

# put a proxy in place until apt-fast script is actually
# installed by site_apt::apt_fast
unless File.exists?(APT_FAST_PATH)
  `ln -s /usr/bin/apt-get #{APT_FAST_PATH}`
end

Puppet::Type.type(:package).provide :aptfast, :parent => :apt, :source => :dpkg do

  desc "Package management via `apt-fast`."

  commands :aptget => APT_FAST_PATH

  defaultfor :operatingsystem => [:debian, :ubuntu]

end
