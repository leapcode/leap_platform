begin
  require 'facter/util/debian'
rescue LoadError
  require "#{File.dirname(__FILE__)}/util/debian"
end

def debian_codename_to_next(codename)
  if codename == "sid"
    return "experimental"
  else
    codenames = Facter::Util::Debian::CODENAMES
    versions  = Facter::Util::Debian::CODENAMES.invert
    current_version = versions[codename]
    return codenames[(current_version.to_i + 1).to_s]
  end
end

Facter.add(:debian_nextcodename) do
  confine :operatingsystem => 'Debian'
  setcode do
    debian_codename_to_next(Facter.value('debian_codename'))
  end
end
