# adds netmask facts for each interface in cidr notation
# i.e.:
# ...
# netmask_cidr_eth2 => 24
# netmask_cidr_lo => 8
# netmask_cidr_tun0 => 32
# netmask_cidr_virbr0 => 24
# ...

require 'facter/util/ip'

Facter::Util::IP.get_interfaces.each do |interface|
  netmask = Facter.value("netmask_#{interface}")
  if netmask != nil
    Facter.add("netmask_cidr_" + interface ) do
      setcode do
        cidr_netmask=IPAddr.new(netmask).to_i.to_s(2).count("1")
        cidr_netmask
      end
    end
  end
end
