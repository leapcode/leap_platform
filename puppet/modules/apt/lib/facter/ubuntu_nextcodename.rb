begin
  require 'facter/util/ubuntu'
rescue LoadError
  require "#{File.dirname(__FILE__)}/util/ubuntu"
end

def ubuntu_codename_to_next(codename)
  codenames = Facter::Util::Ubuntu::CODENAMES
  i = codenames.index(codename)
  if i and i+1 < codenames.count
    return codenames[i+1]
  end
end

Facter.add(:ubuntu_nextcodename) do
  confine :operatingsystem => 'Ubuntu'
  setcode do
    ubuntu_codename_to_next(Facter.value('ubuntu_codename'))
  end
end
