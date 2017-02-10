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
    assert_running match: '^/usr/sbin/apache2'
    assert_running match: 'ruby /usr/bin/nickserver'
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
          assert_user_db_privileges(user)
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
  # checks if user db exists and is properly protected
  #
  def assert_user_db_privileges(user)
    db_name = "/user-#{user.id}"
    get(couchdb_url(db_name)) do |body, response, error|
      code = response.code.to_i
      assert code != 404, "Could not find user db `#{db_name}` for test user `#{user.username}`\nuuid=#{user.id}\nHTTP #{response.code} #{error} #{body}"
      # After moving to couchdb, webapp user is not allowed to Read user dbs,
      # but the return code for non-existent databases is 404. See #7674
      # 401 should come as we aren't supposed to have read privileges on it.
      assert code != 200, "Incorrect security settings (design doc) on user db `#{db_name}` for test user `#{user.username}`\nuuid=#{user.id}\nHTTP #{response.code} #{error} #{body}"
      assert code == 401, "Unknown error on user db on user db `#{db_name}` for test user `#{user.username}`\nuuid=#{user.id}\nHTTP #{response.code} #{error} #{body}"
    end
  end

end
