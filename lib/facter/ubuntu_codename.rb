Facter.add(:ubuntu_codename) do
  confine :operatingsystem => 'Ubuntu'
  setcode do
    Facter.value('lsbdistcodename')
  end
end


