class LeapTest

  #
  # generates a couchdb url for when couchdb is running
  # remotely and is available via stunnel.
  #
  # example properties:
  #
  # stunnel:
  #   clients:
  #     couch_client:
  #       couch1_5984:
  #         accept_port: 4000
  #         connect: couch1.bitmask.i
  #         connect_port: 15984
  #
  def couchdb_urls_via_stunnel(path="", options=nil)
    path = path.gsub('"', '%22')
    if options && options[:username] && options[:password]
      userpart = "%{username}:%{password}@" % options
    else
      userpart = ""
    end
    assert_property('stunnel.clients.couch_client').values.collect do |stunnel_conf|
      assert port = stunnel_conf['accept_port'], 'Field `accept_port` must be present in `stunnel` property.'
      URLString.new("http://#{userpart}localhost:#{port}#{path}").tap {|url|
        remote_ip_address = TCPSocket.gethostbyname(stunnel_conf['connect']).last
        url.memo = "(via stunnel to %s:%s, aka %s)" % [stunnel_conf['connect'], stunnel_conf['connect_port'], remote_ip_address]
      }
    end
  end

  #
  # generates a couchdb url for accessing couchdb via haproxy
  #
  # example properties:
  #
  # haproxy:
  #   couch:
  #     listen_port: 4096
  #     servers:
  #       panda:
  #         backup: false
  #         host: localhost
  #         port: 4000
  #         weight: 100
  #         writable: true
  #
  def couchdb_url_via_haproxy(path="", options=nil)
    path = path.gsub('"', '%22')
    if options && options[:username] && options[:password]
      userpart = "%{username}:%{password}@" % options
    else
      userpart = ""
    end
    port = assert_property('haproxy.couch.listen_port')
    return URLString.new("http://#{userpart}localhost:#{port}#{path}").tap { |url|
      url.memo = '(via haproxy)'
    }
  end

  #
  # generates a couchdb url for when couchdb is running locally.
  #
  # example properties:
  #
  # couch:
  #   port: 5984
  #
  def couchdb_url_via_localhost(path="", options=nil)
    path = path.gsub('"', '%22')
    port = (options && options[:port]) || assert_property('couch.port')
    if options && options[:username]
      password = property("couch.users.%{username}.password" % options)
      userpart = "%s:%s@" % [options[:username], password]
    else
      userpart = ""
    end
    return URLString.new("http://#{userpart}localhost:#{port}#{path}").tap { |url|
      url.memo = '(via direct localhost connection)'
    }
  end

  #
  # returns a single url for accessing couchdb
  #
  def couchdb_url(path="", options=nil)
    if property('couch.port')
      couchdb_url_via_localhost(path, options)
    elsif property('stunnel.clients.couch_client')
      couchdb_urls_via_stunnel(path, options).first
    end
  end

  #
  # returns an array of urls for accessing couchdb
  #
  def couchdb_urls(path="", options=nil)
    if property('couch.port')
      [couchdb_url_via_localhost(path, options)]
    elsif property('stunnel.clients.couch_client')
      couchdb_urls_via_stunnel(path, options)
    end
  end

  def assert_destroy_user_db(user_id, options=nil)
    db_name = "user-#{user_id}"
    url = couchdb_url("/#{db_name}", options)
    http_options = {:ok_codes => [200, 404]} # ignore missing dbs
    assert_delete(url, nil, http_options)
  end

  def assert_create_user_db(user_id, options=nil)
    db_name = "user-#{user_id}"
    url = couchdb_url("/#{db_name}", options)
    http_options = {:ok_codes => [200, 404]} # ignore missing dbs
    assert_put(url, nil, :format => :json) do |body|
      assert response = JSON.parse(body), "PUT response should be JSON"
      assert response["ok"], "PUT response should be OK"
    end
  end

  #
  # returns true if the per-user db created by soledad-server exists.
  #
  def user_db_exists?(user_id, options=nil)
    db_name = "user-#{user_id}"
    url = couchdb_url("/#{db_name}", options)
    get(url) do |body, response, error|
      if response.nil?
        fail "could not query couchdb #{url}: #{error}\n#{body}"
      elsif response.code.to_i == 200
        return true
      elsif response.code.to_i == 404
        return false
      else
        fail ["could not query couchdb #{url}: expected response code 200 or 404, but got #{response.code}.", error, body].compact.join("\n")
      end
    end
  end

end