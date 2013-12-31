raise SkipTest unless $node["services"].include?("openvpn")

class TestOpenvpn < LeapTest
  depends_on "TestNetwork"

  def setup
  end

  def test_01_daemons_running
    assert_running '/usr/sbin/openvpn .* /etc/openvpn/tcp_config.conf'
    assert_running '/usr/sbin/openvpn .* /etc/openvpn/udp_config.conf'
    assert_running '/usr/sbin/unbound'
    pass
  end

end
