#
# helper for the communication with the provider API for creating, authenticating, and deleting accounts.
#

class LeapTest

  def assert_tmp_user
    user = assert_create_user
    assert_authenticate_user(user)
    yield user if block_given?
  rescue
    # ^^ ensure here would eat any failed assertions
    assert_delete_user(user)
    raise
  end

  def api_url(path)
    api = property('api')
    "https://%{domain}:%{port}#{path}" % {
      :domain   => api['domain'],
      :port     => api['port']
    }
  end

  #
  # attempts to create a user account via the API,
  # returning the user object if successful.
  #
  def assert_create_user
    user = SRP::User.new
    url = api_url("/1/users.json")
    assert_post(url, user.to_params) do |body|
      assert response = JSON.parse(body), 'response should be JSON'
      assert response['ok'], 'creating a user should be successful'
    end
    user.ok = true
    return user
  end

  #
  # attempts to authenticate user. if successful,
  # user object is updated with id and session token.
  #
  def assert_authenticate_user(user)
    url = api_url("/1/sessions.json")
    session = SRP::Session.new(user)
    params = {'login' => user.username, 'A' => session.aa}
    assert_post(url, params) do |response, body|
      cookie = response['Set-Cookie'].split(';').first
      assert(response = JSON.parse(body), 'response should be JSON')
      assert(session.bb = response["B"], 'response should include "B"')
      url = api_url("/1/sessions/login.json")
      params = {'client_auth' => session.m, 'A' => session.aa}
      options = {:headers => {'Cookie' => cookie}}
      assert_put(url, params, options) do |body|
        assert(response = JSON.parse(body), 'response should be JSON')
        assert(response['M2'], 'response should include M2')
        user.session_token = response['token']
        user.id = response['id']
        assert(user.session_token, 'response should include token')
        assert(user.id, 'response should include user id')
      end
    end
  end

  #
  # attempts to destroy a user account via the API.
  #
  def assert_delete_user(user)
    if user && user.ok && user.id && user.session_token
      url = api_url("/1/users/#{user.id}.json")
      options = {:headers => {
        "Authorization" => "Token token=\"#{user.session_token}\""
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

end
