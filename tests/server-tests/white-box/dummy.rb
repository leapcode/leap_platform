# only run in the dummy case where there is no hiera.yaml file.
raise SkipTest unless $node["dummy"]

class Robot
  def can_shoot_lasers?
    "OHAI!"
  end

  def can_fly?
    "YES!"
  end
end

class TestDummy < LeapTest
  def setup
    @robot = Robot.new
  end

  def test_lasers
    assert_equal "OHAI!", @robot.can_shoot_lasers?
    pass
  end

  def test_fly
    refute_match /^no/i, @robot.can_fly?
    pass
  end

  def test_fail
    fail "fail"
    pass
  end

  def test_01_will_be_skipped
    skip "test this later"
    pass
  end

  def test_socket_failure
    assert_tcp_socket('localhost', 900000)
    pass
  end

  def test_warn
    block_test do
      warn "not everything", "is a success or failure"
    end
  end

  # used to test extracting the proper caller even when in a block
  def block_test
    yield
  end

  def test_socket_success
    fork {
      Socket.tcp_server_loop('localhost', 12345) do |sock, client_addrinfo|
        begin
          sock.write('hi')
        ensure
          sock.close
          exit
        end
      end
    }
    sleep 0.2
    assert_tcp_socket('localhost', 12345)
    pass
  end

end
