require 'socket'
require 'openssl'

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
    release = `facter lsbmajdistrelease`
    if release.to_i > 7
      # on jessie, there is only one stunnel proc running instead of 6
      expected = 1
    else
      expected = 6
    end
    $node['stunnel']['clients'].each do |stunnel_type, stunnel_configs|
      stunnel_configs.each do |stunnel_name, stunnel_conf|
        config_file_name = "/etc/stunnel/#{stunnel_name}.conf"
        processes = pgrep(config_file_name)
        assert_equal expected, processes.length, "There should be #{expected} stunnel processes running for `#{config_file_name}`"
        good_stunnel_pids += processes.map{|ps| ps[:pid]}
        assert port = stunnel_conf['accept_port'], 'Field `accept_port` must be present in `stunnel` property.'
        assert_tcp_socket('localhost', port)
      end
    end
    $node['stunnel']['servers'].each do |stunnel_name, stunnel_conf|
      config_file_name = "/etc/stunnel/#{stunnel_name}.conf"
      processes = pgrep(config_file_name)
      assert_equal expected, processes.length, "There should be #{expected} stunnel processes running for `#{config_file_name}`"
      good_stunnel_pids += processes.map{|ps| ps[:pid]}
      assert accept_port = stunnel_conf['accept_port'], "Field `accept` must be present in property `stunnel.servers.#{stunnel_name}`"
      assert_tcp_socket('localhost', accept_port)
      assert connect_port = stunnel_conf['connect_port'], "Field `connect` must be present in property `stunnel.servers.#{stunnel_name}`"
      assert_tcp_socket('localhost', connect_port,
        "The local connect endpoint for stunnel `#{stunnel_name}` is unavailable.\n"+
        "This is probably caused by a daemon that died or failed to start on\n"+
        "port `#{connect_port}`, not stunnel itself.")
    end
    all_stunnel_pids = pgrep('/usr/bin/stunnel').collect{|process| process[:pid]}.uniq
    assert_equal good_stunnel_pids.sort, all_stunnel_pids.sort, "There should not be any extra stunnel processes that are not configured in /etc/stunnel"
    pass
  end

  def test_03_Is_shorewall_running?
    ignore unless File.exists?('/sbin/shorewall')
    assert_run('/sbin/shorewall status')
    pass
  end

  THIRTY_DAYS = 60*60*24*30

  def test_04_Are_server_certificates_valid?
    cert_paths = ["/etc/x509/certs/leap_commercial.crt", "/etc/x509/certs/leap.crt"]
    cert_paths.each do |cert_path|
      if File.exists?(cert_path)
        cert = OpenSSL::X509::Certificate.new(File.read(cert_path))
        if cert.not_after > Time.now
          fail "The certificate #{cert_path} expired on #{cert.not_after}"
        elsif cert.not_after > Time.now + THIRTY_DAYS
          fail "The certificate #{cert_path} will expire soon, on #{cert.not_after}"
        end
      end
    end
    pass
  end

end
