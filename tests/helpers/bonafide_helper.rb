#
# helper for the communication with the provider API for creating, authenticating, and deleting accounts.
#

class LeapTest

  def assert_tmp_user
    user = assert_create_user
    assert_authenticate_user(user)
    yield user if block_given?
    assert_delete_user(user)
  rescue StandardError, MiniTest::Assertion => exc
    begin
      assert_delete_user(user)
    rescue
    end
    raise exc
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

    params = user.to_params

    if property('webapp.invite_required')
      @invite_code = generate_invite_code
      params['user[invite_code]'] = @invite_code
    end

    assert_post(url, params) do |body|
      assert response = JSON.parse(body), 'response should be JSON'
      assert response['ok'], "Creating a user should be successful, got #{response.inspect} instead."
    end
    user.ok = true
    return user
  end

  def generate_invite_code
    `cd /srv/leap/webapp/ && sudo -u leap-webapp RAILS_ENV=production bundle exec rake generate_invites[1]`.gsub(/\n/, "")
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
    if user && user.ok && user.id && user.session_token && !user.deleted
      url = api_url("/1/users/#{user.id}.json")
      options = {:headers => {
        "Authorization" => "Token token=\"#{user.session_token}\""
      }}
      params = {
        :identities => 'destroy'
      }
      user.deleted = true
      delete(url, params, options) do |body, response, error|
        assert error.nil?, "Error deleting user: #{error}"
        assert response.code.to_i == 200, "Unable to delete user: HTTP response from API should have code 200, was #{response.code} #{error} #{body}"
        assert(response = JSON.parse(body), 'Delete response should be JSON')
        assert(response["success"], 'Deleting user should be a success')
      end
    end
  end

end
