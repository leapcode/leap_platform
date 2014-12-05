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

  def test_05_Can_create_and_authenticate_and_delete_user_via_API?
    assert_tmp_user
    pass
  end

  def test_06_Can_sync_Soledad?
    soledad_config = property('definition_files.soledad_service')
    if soledad_config && !soledad_config.empty?
      soledad_server = pick_soledad_server(soledad_config)
      assert_tmp_user do |user|
        assert_user_db_exists(user)
        command = File.expand_path "../../helpers/soledad_sync.py", __FILE__
        soledad_url = "https://#{soledad_server}/user-#{user.id}"
        assert_run "#{command} #{user.id} #{user.session_token} #{soledad_url}"
        pass
      end
    else
      skip 'No soledad service configuration'
    end
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
    hostname = soledad_config['hosts'][host_name]['hostname']
    port = soledad_config['hosts'][host_name]['port']
    return "#{hostname}:#{port}"
  end

  #
  # returns true if the per-user db created by tapicero exists.
  # we try three times, and give up after that.
  #
  def assert_user_db_exists(user)
    last_body, last_response, last_error = nil
    3.times do
      sleep 0.1
      get(couchdb_url("/user-#{user.id}/_design/docs")) do |body, response, error|
        last_body, last_response, last_error = body, response, error
        if response.code.to_i == 200
          return
        end
      end
      sleep 0.2
    end
    assert false, "Could not find user db for test user #{user.username}\nuuid=#{user.id}\nHTTP #{last_response.code} #{last_error} #{last_body}"
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
