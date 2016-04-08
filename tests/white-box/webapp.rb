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
    assert_running '^/usr/sbin/apache2'
    assert_running '^/usr/bin/ruby /usr/bin/nickserver'
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

  def test_05_Can_create_and_authenticate_and_delete_user_via_API?
    if property('webapp.allow_registration')
      assert_tmp_user
      pass
    else
      skip "New user registrations are disabled."
    end
  end

  def test_06_Can_sync_Soledad?
    return unless property('webapp.allow_registration')
    soledad_config = property('definition_files.soledad_service')
    if soledad_config && !soledad_config.empty?
      soledad_server = pick_soledad_server(soledad_config)
      if soledad_server
        assert_tmp_user do |user|
          command = File.expand_path "../../helpers/soledad_sync.py", __FILE__
          soledad_url = "https://#{soledad_server}/user-#{user.id}"
          soledad_cert = "/usr/local/share/ca-certificates/leap_ca.crt"
          assert_run "#{command} #{user.id} #{user.session_token} #{soledad_url} #{soledad_cert} #{user.password}"
          assert_user_db_exists(user)
          pass
        end
      end
    else
      skip 'No soledad service configuration'
    end
  end

  private

  def url_options
    {
      :username => property('webapp.couchdb_webapp_user.username'),
      :password => property('webapp.couchdb_webapp_user.password')
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
        # After moving to couchdb, webapp user is not allowed to Read user dbs,
        # but the return code for non-existent databases is 404. See #7674
        if response.code.to_i == 401
          return
        end
      end
      sleep 1
    end
    yield last_body, last_response, last_error
    return
  end

end
