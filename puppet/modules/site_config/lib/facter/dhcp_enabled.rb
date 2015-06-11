require 'facter'
def dhcp_enabled?(ifs, recurse=true)
  dhcp = false
  included_ifs = []
  if FileTest.exists?(ifs)
    File.open(ifs) do |file|
      dhcp = file.enum_for(:each_line).any? do |line|
        if recurse && line =~ /^\s*source\s+([^\s]+)/
          included_ifs += Dir.glob($1)
        end
        line =~ /inet\s+dhcp/
      end
    end
  end
  dhcp || included_ifs.any? { |ifs| dhcp_enabled?(ifs, false) }
end
Facter.add(:dhcp_enabled) do
  confine :osfamily => 'Debian'
  setcode do
    dhcp_enabled?('/etc/network/interfaces')
  end
end
