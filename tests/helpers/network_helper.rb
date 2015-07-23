class LeapTest

  #
  # tcp connection helper with timeout
  #
  def try_tcp_connect(host, port, timeout = 5)
    addr     = Socket.getaddrinfo(host, nil)
    sockaddr = Socket.pack_sockaddr_in(port, addr[0][3])

    Socket.new(Socket.const_get(addr[0][0]), Socket::SOCK_STREAM, 0).tap do |socket|
      socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
      begin
        socket.connect_nonblock(sockaddr)
      rescue IO::WaitReadable
        if IO.select([socket], nil, nil, timeout) == nil
          raise "Connection timeout"
        else
          socket.connect_nonblock(sockaddr)
        end
      rescue IO::WaitWritable
        if IO.select(nil, [socket], nil, timeout) == nil
          raise "Connection timeout"
        else
          socket.connect_nonblock(sockaddr)
        end
      end
      return socket
    end
  end

  def try_tcp_write(socket, timeout = 5)
    begin
      socket.write_nonblock("\0")
    rescue IO::WaitReadable
      if IO.select([socket], nil, nil, timeout) == nil
        raise "Write timeout"
      else
        retry
      end
    rescue IO::WaitWritable
      if IO.select(nil, [socket], nil, timeout) == nil
        raise "Write timeout"
      else
        retry
      end
    end
  end

  def try_tcp_read(socket, timeout = 5)
    begin
      socket.read_nonblock(1)
    rescue IO::WaitReadable
      if IO.select([socket], nil, nil, timeout) == nil
        raise "Read timeout"
      else
        retry
      end
    rescue IO::WaitWritable
      if IO.select(nil, [socket], nil, timeout) == nil
        raise "Read timeout"
      else
        retry
      end
    end
  end

  def assert_tcp_socket(host, port, msg=nil)
    begin
      socket = try_tcp_connect(host, port, 1)
      #try_tcp_write(socket,1)
      #try_tcp_read(socket,1)
    rescue StandardError => exc
      fail ["Failed to open socket #{host}:#{port}", exc, msg].compact.join("\n")
    ensure
      socket.close if socket
    end
  end

end