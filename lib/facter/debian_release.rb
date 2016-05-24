begin
  require 'facter/util/debian'
rescue LoadError
  require "#{File.dirname(__FILE__)}/util/debian"
end

def debian_codename_to_release(codename)
  stable = Facter::Util::Debian::STABLE
  versions = Facter::Util::Debian::CODENAMES.invert
  release = nil
  if codename == "sid"
    release = "unstable"
  elsif versions.has_key? codename
    version = versions[codename].to_i
    if version == stable
      release = "stable"
    elsif version < stable
      release = "stable"
      for i in version..stable - 1
        release = "old" + release
      end
    elsif version == stable + 1
      release = "testing"
    end
  end
  if release.nil?
    Facter.warn("Could not determine release from codename #{codename}!")
  end
  return release
end

Facter.add(:debian_release) do
  has_weight 99
  confine :operatingsystem => 'Debian'
  setcode do
    debian_codename_to_release(Facter.value('debian_codename'))
  end
end
