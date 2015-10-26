raise SkipTest unless service?(:webapp)

require 'json'

class Webapp < LeapTest
  depends_on "Network"

  def setup
  end

  def test_01_Can_contact_couchdb?
    url = couchdb_url("", url_options)
    assert_get(url) do |body|
      assert_match /"couchdb":"Welcome"/, body, "Request to #{url} should return couchdb welcome message."
    end
    pass
  end

  def test_02_Can_contact_couchdb_via_haproxy?
    if property('haproxy.couch')
      url = couchdb_url_via_haproxy("", url_options)
      assert_get(url) do |body|
        assert_match /"couchdb":"Welcome"/, body, "Request to #{url} should return couchdb welcome message."
      end
      pass
    end
  end

  def test_03_Are_daemons_running?
    assert_running '/usr/sbin/apache2'
    assert_running '/usr/bin/nickserver'
    pass
  end

  #
  # this is technically a black-box test. so, move this when we have support
  # for black box tests.
  #
  def test_04_Can_access_webapp?
    assert_get('https://' + $node['webapp']['domain'] + '/')
    pass
  end

  private

  def url_options
    {
      :username => property('couchdb_webapp_user.username'),
      :password => property('couchdb_webapp_user.password')
    }
  end

  #
  # pick a random soledad server.
  # I am not sure why, but using IP address directly does not work.
  #
  def pick_soledad_server(soledad_config_json_str)
    soledad_config = JSON.parse(soledad_config_json_str)
    host_name = soledad_config['hosts'].keys.shuffle.first
    if host_name
      hostname = soledad_config['hosts'][host_name]['hostname']
      port = soledad_config['hosts'][host_name]['port']
      return "#{hostname}:#{port}"
    else
      return nil
    end
  end

  #
  # returns true if the per-user db created by soledad-server exists.
  # we try three times, and give up after that.
  #
  def assert_user_db_exists(user)
    db_name = "user-#{user.id}"
    repeatedly_try("/#{db_name}") do |body, response, error|
      assert false, "Could not find user db `#{db_name}` for test user `#{user.username}`\nuuid=#{user.id}\nHTTP #{response.code} #{error} #{body}"
    end
    repeatedly_try("/#{db_name}/_design/docs") do |body, response, error|
      assert false, "Could not find design docs for user db `#{db_name}` for test user `#{user.username}`\nuuid=#{user.id}\nHTTP #{response.code} #{error} #{body}"
    end
  end

  #
  # tries the URL repeatedly, giving up and yield the last response if
  # no try returned a 200 http status code.
  #
  def repeatedly_try(url, &block)
    last_body, last_response, last_error = nil
    3.times do
      sleep 0.2
      get(couchdb_url(url)) do |body, response, error|
        last_body, last_response, last_error = body, response, error
        if response.code.to_i == 200
          return
        end
      end
      sleep 1
    end
    yield last_body, last_response, last_error
    return
  end

  #
  # I tried, but couldn't get this working:
  # #
  # # get an CSRF authenticity token
  # #
  # url = api_url("/")
  # csrf_token = nil
  # assert_get(url) do |body|
  #   lines = body.split("\n").grep(/csrf-token/)
  #   assert lines.any?, 'failed to find csrf-token'
  #   csrf_token = lines.first.split('"')[1]
  #   assert csrf_token, 'failed to find csrf-token'
  # end

end
