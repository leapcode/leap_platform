require 'socket'

raise SkipTest if $node["dummy"]

class TestNetwork < LeapTest

  def setup
  end

  #
  # example properties:
  #
  # stunnel:
  #   ednp_clients:
  #     elk_9002:
  #       accept_port: 4003
  #       connect: elk.dev.bitmask.i
  #       connect_port: 19002
  #   couch_server:
  #     accept: 15984
  #     connect: "127.0.0.1:5984"
  #
  def test_01_stunnel_is_running
    if $node['stunnel']
      $node['stunnel'].each do |stunnel_type, stunnel_configs|
        if stunnel_type =~ /_clients?$/
          stunnel_configs.values.each do |stunnel_conf|
            assert port = stunnel_conf['accept_port'], 'Field `accept_port` must be present in `stunnel` property.'
            assert_tcp_socket('localhost', port)
          end
        elsif stunnel_type =~ /_server$/
          assert accept = stunnel_configs['accept'], "Field `accept` must be present in property `stunnel.#{stunnel_type}`"
          assert_tcp_socket('localhost', accept)
          assert connect = stunnel_configs['connect'], "Field `connect` must be present in property `stunnel.#{stunnel_type}`"
          assert_tcp_socket(*connect.split(':'))
        else
          skip "Unknown stunnel type `#{stunnel_type}`"
        end
      end
    end
    pass
  end

end
