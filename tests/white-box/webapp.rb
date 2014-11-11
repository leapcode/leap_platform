raise SkipTest unless $node["services"].include?("webapp")

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

  def test_05_Can_create_user?
    @@user = nil
    user = SRP::User.new
    url = api_url("/1/users.json")
    assert_post(url, user.to_params) do |body|
      assert response = JSON.parse(body), 'response should be JSON'
      assert response['ok'], 'creating a user should be successful'
    end
    @@user = user
    pass
  end

  def test_06_Can_authenticate?
    @@user_id = nil
    @@session_token = nil
    if @@user.nil?
      skip "Depends on user creation"
    else
      url = api_url("/1/sessions.json")
      session = SRP::Session.new(@@user)
      params = {'login' => @@user.username, 'A' => session.aa}
      assert_post(url, params) do |response, body|
        cookie = response['Set-Cookie'].split(';').first
        assert(response = JSON.parse(body), 'response should be JSON')
        assert(bb = response["B"])
        session.bb = bb
        url = api_url("/1/sessions/login.json")
        params = {'client_auth' => session.m, 'A' => session.aa}
        options = {:headers => {'Cookie' => cookie}}
        assert_put(url, params, options) do |body|
          assert(response = JSON.parse(body), 'response should be JSON')
          assert(response['M2'], 'response should include M2')
          assert(@@session_token = response['token'], 'response should include token')
          assert(@@user_id = response['id'], 'response should include user id')
        end
      end
      pass
    end
  end

  def test_07_Can_delete_user?
    if @@user_id.nil? || @@session_token.nil?
      skip "Depends on authentication"
    else
      url = api_url("/1/users/#{@@user_id}.json")
      options = {:headers => {
        "Authorization" => "Token token=\"#{@@session_token}\""
      }}
      delete(url, {}, options) do |body, response, error|
        if response.code.to_i != 200
          skip "It appears the web api is too old to support deleting users"
        else
          assert(response = JSON.parse(body), 'response should be JSON')
          assert(response["success"], 'delete should be a success')
          pass
        end
      end
    end
  end

  private

  def url_options
    {
      :username => property('couchdb_webapp_user.username'),
      :password => property('couchdb_webapp_user.password')
    }
  end

  def api_url(path)
    "https://%{domain}:%{port}#{path}" % {
      :domain   => property('api.domain'),
      :port     => property('api.port')
    }
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
