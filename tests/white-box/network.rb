require 'socket'

raise SkipTest if $node["dummy"]

class Network < LeapTest

  def setup
  end

  def test_01_Can_connect_to_internet?
    assert_get('http://www.google.com/images/srpr/logo11w.png')
    pass
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
  def test_02_Is_stunnel_running?
    if $node['stunnel']
      good_stunnel_pids = []
      $node['stunnel'].each do |stunnel_type, stunnel_configs|
        if stunnel_type =~ /_clients?$/
          stunnel_configs.each do |stunnel_name, stunnel_conf|
            config_file_name = "/etc/stunnel/#{stunnel_name}.conf"
            processes = pgrep(config_file_name)
            assert_equal 6, processes.length, "There should be six stunnel processes running for `#{config_file_name}`"
            good_stunnel_pids += processes.map{|ps| ps[:pid]}
            assert port = stunnel_conf['accept_port'], 'Field `accept_port` must be present in `stunnel` property.'
            assert_tcp_socket('localhost', port)
          end
        elsif stunnel_type =~ /_server$/
          config_file_name = "/etc/stunnel/#{stunnel_type}.conf"
          processes = pgrep(config_file_name)
          assert_equal 6, processes.length, "There should be six stunnel processes running for `#{config_file_name}`"
          good_stunnel_pids += processes.map{|ps| ps[:pid]}
          assert accept = stunnel_configs['accept'], "Field `accept` must be present in property `stunnel.#{stunnel_type}`"
          assert_tcp_socket('localhost', accept)
          assert connect = stunnel_configs['connect'], "Field `connect` must be present in property `stunnel.#{stunnel_type}`"
          assert_tcp_socket(*connect.split(':'))
        else
          skip "Unknown stunnel type `#{stunnel_type}`"
        end
      end
      all_stunnel_pids = pgrep('/usr/bin/stunnel').collect{|process| process[:pid]}.uniq
      assert_equal good_stunnel_pids.sort, all_stunnel_pids.sort, "There should not be any extra stunnel processes that are not configured in /etc/stunnel"
      pass
    end
  end

end
