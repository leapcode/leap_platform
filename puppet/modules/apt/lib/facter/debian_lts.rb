begin
  require 'facter/util/debian'
rescue LoadError
  require "#{File.dirname(__FILE__)}/util/debian"
end

Facter.add(:debian_lts) do
  confine :operatingsystem => 'Debian'
  setcode do
    if Facter::Util::Debian::LTS.include? Facter.value('debian_codename')
      true
    else
      false
    end
  end
end
