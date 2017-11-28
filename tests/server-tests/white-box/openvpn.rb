raise SkipTest unless service?(:openvpn)

class OpenVPN < LeapTest
  depends_on "Network"

  def setup
  end

  def test_01_Are_daemons_running?
    assert_running match: '^/usr/sbin/openvpn .* /etc/openvpn/tcp_config.conf$'
    assert_running match: '^/usr/sbin/openvpn .* /etc/openvpn/udp_config.conf$'
    assert_running match: '^/usr/sbin/unbound'
    pass
  end

  def test_02_Can_connect_to_openvpn?
    # because of the way the firewall rules are currently set up, you can only
    # connect to the standard 1194 openvpn port when you are connecting
    # from the same host as openvpn is running on.
    #
    # so, this is disabled for now:
    # $node['openvpn']['ports'].each {|port| ...}
    #

    $node['openvpn']['protocols'].each do |protocol|
      assert_openvpn_is_bound_to_port($node['openvpn']['gateway_address'], protocol, 1194)
    end
    pass
  end

  private

  #
  # asserting succeeds if openvpn appears to be correctly bound and we can
  # connect to it. we don't actually try to establish a vpn connection in this
  # test, we just check to see that it sort of looks like it is openvpn running
  # on the port.
  #
  def assert_openvpn_is_bound_to_port(ip_address, protocol, port)
    protocol = protocol.downcase
    if protocol == 'udp'
      # this sends a magic string to openvpn to attempt to start the protocol.
      nc_output = `/bin/echo -e "\\x38\\x01\\x00\\x00\\x00\\x00\\x00\\x00\\x00" | timeout 0.5 nc -u #{ip_address} #{port}`.strip
      assert !nc_output.empty?, "Could not connect to OpenVPN daemon at #{ip_address} on port #{port} (#{protocol})."
    elsif protocol == 'tcp'
      assert system("openssl s_client -connect #{ip_address}:#{port} 2>&1 | grep -q CONNECTED"),
        "Could not connect to OpenVPN daemon at #{ip_address} on port #{port} (#{protocol})."
    else
      assert false, "invalid openvpn protocol #{protocol}"
    end
  end
end
