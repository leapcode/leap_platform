raise SkipTest unless $node["services"].include?("webapp")

require 'socket'

class TestWebapp < LeapTest
  depends_on "TestNetwork"

  HAPROXY_CONFIG = '/etc/haproxy/haproxy.cfg'

  def setup
  end

  #
  # example properties:
  #
  # stunnel:
  #   couch_client:
  #     couch1_5984:
  #       accept_port: 4000
  #       connect: couch1.bitmask.i
  #       connect_port: 15984
  #
  def test_01_can_contact_couchdb
    assert_property('stunnel.couch_client')
    $node['stunnel']['couch_client'].values.each do |stunnel_conf|
      assert port = stunnel_conf['accept_port'], 'Field `accept_port` must be present in `stunnel` property.'
      local_stunnel_url = "http://localhost:#{port}"
      remote_ip_address = TCPSocket.gethostbyname(stunnel_conf['connect']).last
      msg = "(stunnel to %s:%s, aka %s)" % [stunnel_conf['connect'], stunnel_conf['connect_port'], remote_ip_address]
      assert_get(local_stunnel_url, nil, error_msg: msg) do |body|
        assert_match /"couchdb":"Welcome"/, body, "Request to #{local_stunnel_url} should return couchdb welcome message."
      end
    end
    pass
  end

  #
  # example properties:
  #
  # haproxy:
  #   servers:
  #     couch1:
  #       backup: false
  #       host: localhost
  #       port: 4000
  #       weight: 10
  #
  def test_02_haproxy_is_working
    port = file_match(HAPROXY_CONFIG, /^  bind localhost:(\d+)$/)
    url = "http://localhost:#{port}"
    assert_get(url) do |body|
      assert_match /"couchdb":"Welcome"/, body, "Request to #{url} should return couchdb welcome message."
    end
    pass
  end

end
