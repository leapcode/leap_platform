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

end
