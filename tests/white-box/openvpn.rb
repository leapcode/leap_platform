raise SkipTest unless $node["services"].include?("openvpn")

class Openvpn < LeapTest
  depends_on "Network"

  def setup
  end

  def test_01_Are_daemons_running?
    assert_running '/usr/sbin/openvpn .* /etc/openvpn/tcp_config.conf'
    assert_running '/usr/sbin/openvpn .* /etc/openvpn/udp_config.conf'
    assert_running '/usr/sbin/unbound'
    pass
  end

end
