Facter.add("apt_running") do
  setcode do
    #Facter::Util::Resolution.exec('/usr/bin/dpkg -s mysql-server >/dev/null 2>&1 && echo true || echo false')
    Facter::Util::Resolution.exec('pgrep apt-get >/dev/null 2>&1 && echo true || echo false')
  end
end

