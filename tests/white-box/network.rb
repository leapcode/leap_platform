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
    ignore unless $node['stunnel']
    good_stunnel_pids = []
    $node['stunnel']['clients'].each do |stunnel_type, stunnel_configs|
      stunnel_configs.each do |stunnel_name, stunnel_conf|
        config_file_name = "/etc/stunnel/#{stunnel_name}.conf"
        processes = pgrep(config_file_name)
        assert_equal 6, processes.length, "There should be six stunnel processes running for `#{config_file_name}`"
        good_stunnel_pids += processes.map{|ps| ps[:pid]}
        assert port = stunnel_conf['accept_port'], 'Field `accept_port` must be present in `stunnel` property.'
        assert_tcp_socket('localhost', port)
      end
    end
    $node['stunnel']['servers'].each do |stunnel_name, stunnel_conf|
      config_file_name = "/etc/stunnel/#{stunnel_name}.conf"
      processes = pgrep(config_file_name)
      assert_equal 6, processes.length, "There should be six stunnel processes running for `#{config_file_name}`"
      good_stunnel_pids += processes.map{|ps| ps[:pid]}
      assert accept_port = stunnel_conf['accept_port'], "Field `accept` must be present in property `stunnel.servers.#{stunnel_name}`"
      assert_tcp_socket('localhost', accept_port)
      assert connect_port = stunnel_conf['connect_port'], "Field `connect` must be present in property `stunnel.servers.#{stunnel_name}`"
      assert_tcp_socket('localhost', connect_port)
    end
    all_stunnel_pids = pgrep('/usr/bin/stunnel').collect{|process| process[:pid]}.uniq
    assert_equal good_stunnel_pids.sort, all_stunnel_pids.sort, "There should not be any extra stunnel processes that are not configured in /etc/stunnel"
    pass
  end

  def test_03_Is_shorewall_running?
    assert_run('/sbin/shorewall status')
    pass
  end

end
