require 'facter/util/ip'

Facter::Util::IP.get_interfaces.each do |interface|
  ip = Facter.value("ipaddress_#{interface}")
  if ip != nil
    Facter.add("interface_" + ip ) do
      setcode do
        interface
      end
    end
  end
end

