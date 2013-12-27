require 'socket'

raise SkipTest if $node["dummy"]

class TestNetwork < LeapTest

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
  def test_01_stunnel_is_running
    if $node['stunnel']
      $node['stunnel'].values.each do |stunnel_type|
        stunnel_type.values.each do |stunnel_conf|
          assert port = stunnel_conf['accept_port'], 'Field `accept_port` must be present in `stunnel` property.'
          assert_tcp_socket('localhost', port)
        end
      end
    end
    pass
  end

end
