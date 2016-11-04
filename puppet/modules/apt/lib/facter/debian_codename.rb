begin
  require 'facter/util/debian'
rescue LoadError
  require "#{File.dirname(__FILE__)}/util/debian"
end

def version_to_codename(version)
  if Facter::Util::Debian::CODENAMES.has_key?(version)
    return Facter::Util::Debian::CODENAMES[version]
  else
    Facter.warn("Could not determine codename from version '#{version}'")
  end
end

Facter.add(:debian_codename) do
  has_weight 99
  confine :operatingsystem => 'Debian'
  setcode do
    Facter.value('lsbdistcodename')
  end
end

Facter.add(:debian_codename) do
  has_weight 66
  confine :operatingsystem => 'Debian'
  setcode do
    version_to_codename(Facter.value('operatingsystemmajrelease'))
  end
end

Facter.add(:debian_codename) do
  has_weight 33
  confine :operatingsystem => 'Debian'
  setcode do
    debian_version = File.open('/etc/debian_version', &:readline)
    if debian_version.match(/^\d+/)
      version_to_codename(debian_version.scan(/^(\d+)/)[0][0])
    elsif debian_version.match(/^[a-z]+\/(sid|unstable)/)
      debian_version.scan(/^([a-z]+)\//)[0][0]
    end
  end
end
