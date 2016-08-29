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

  #
  # attempts to create a user account via the API,
  # returning the user object if successful.
  #
  def assert_create_user(username=nil, auth=nil)
    user = SRP::User.new(username)
    url = api_url("/users.json")
    params = user.to_params
    if auth
      options = api_options(:auth => auth)
    else
      options = api_options
      if property('webapp.invite_required')
        @invite_code = generate_invite_code
        params['user[invite_code]'] = @invite_code
      end
    end

    assert_post(url, params, options) do |body|
      assert response = JSON.parse(body), 'response should be JSON'
      assert response['ok'], "Creating a user should be successful, got #{response.inspect} instead."
      user.ok = true
      user.id = response['id']
    end
    return user
  end

  # TODO: use the api for this instead.
  def generate_invite_code
    `cd /srv/leap/webapp/ && sudo -u leap-webapp RAILS_ENV=production bundle exec rake generate_invites[1]`.gsub(/\n/, "")
  end

  #
  # attempts to authenticate user. if successful,
  # user object is updated with id and session token.
  #
  def assert_authenticate_user(user)
    url = api_url("/sessions.json")
    session = SRP::Session.new(user)
    params = {'login' => user.username, 'A' => session.aa}
    assert_post(url, params, api_options) do |body, response|
      cookie = response['Set-Cookie'].split(';').first
      assert(response = JSON.parse(body), 'response should be JSON')
      assert(session.bb = response["B"], 'response should include "B"')
      url = api_url("/sessions/login.json")
      params = {'client_auth' => session.m, 'A' => session.aa}
      assert_put(url, params, api_options('Cookie' => cookie)) do |body|
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
    if user.is_a? String
      assert_delete_user_by_login(user)
    elsif user.is_a? SRP::User
      assert_delete_srp_user(user)
    end
  end

  #
  # returns true if the identity exists, uses monitor token auth
  #
  def identity_exists?(address)
    url = api_url("/identities/#{URI.encode(address)}.json")
    options = {:ok_codes => [200, 404]}.merge(
      api_options(:auth => :monitor)
    )
    assert_get(url, nil, options) do |body, response|
      return response.code == "200"
    end
  end

  def upload_public_key(user_id, public_key)
    url = api_url("/users/#{user_id}.json")
    params = {"user[public_key]" => public_key}
    assert_put(url, params, api_options(:auth => :monitor))
  end

  #
  # return user document as a Hash. uses monitor token auth
  #
  def find_user_by_id(user_id)
    url = api_url("/users/#{user_id}.json")
    assert_get(url, nil, api_options(:auth => :monitor)) do |body|
      return JSON.parse(body)
    end
  end

  #
  # return user document as a Hash. uses monitor token auth
  # NOTE: this relies on deprecated behavior of the API
  # and will not work when multi-domain support is added.
  #
  def find_user_by_login(login)
    url = api_url("/users/0.json?login=#{login}")
    options = {:ok_codes => [200, 404]}.merge(
      api_options(:auth => :monitor)
    )
    assert_get(url, nil, options) do |body, response|
      if response.code == "200"
        return JSON.parse(body)
      else
        return nil
      end
    end
  end

  private

  def api_url(path)
    unless path =~ /^\//
      path = '/' + path
    end
    if property('testing.api_uri')
      return property('testing.api_uri') + path
    elsif property('api')
      api = property('api')
      return "https://%{domain}:%{port}/%{version}#{path}" % {
        :domain   => api['domain'],
        :port     => api['port'],
        :version  => api['version'] || 1
      }
    else
      fail 'This node needs to have either testing.api_url or api.{domain,port} configured.'
    end
  end

  #
  # produces an options hash used for api http requests.
  #
  # argument options hash gets added to "headers"
  # of the http request.
  #
  # special :auth key in argument will expand to
  # add api_token_auth header.
  #
  # if you want to try manually:
  #
  #   export API_URI=`grep api_uri /etc/leap/hiera.yaml | cut -d\" -f2`
  #   export TOKEN=`grep monitor_auth_token /etc/leap/hiera.yaml | awk '{print $2}'`
  #   curl -H "Accept: application/json" -H "Token: $TOKEN" $API_URI
  #
  def api_options(options={})
    # note: must be :headers, not "headers"
    hsh = {
      :headers => {
        "Accept" => "application/json"
      }
    }
    if options[:auth]
      hsh[:headers].merge!(api_token_auth(options.delete(:auth)))
    end
    hsh[:headers].merge!(options)
    return hsh
  end

  #
  # add token authentication to a http request.
  #
  # returns a hash suitable for adding to the 'headers' option
  # of an http function.
  #
  def api_token_auth(token)
    if token.is_a?(Symbol) && property('testing')
      if token == :monitor
        token_str = property('testing.monitor_auth_token')
      else
        raise ArgumentError.new 'no such token'
      end
    else
      token_str = token
    end
    {"Authorization" => "Token token=\"#{token_str}\""}
  end

  #
  # not actually used in any test, but useful when
  # writing new tests.
  #
  def assert_delete_user_by_login(login_name)
    user = find_user_by_login(login_name)
    url = api_url("/users/#{user['id']}.json")
    params =  {:identities => 'destroy'}
    delete(url, params, api_options(:auth => :monitor)) do |body, response, error|
      assert error.nil?, "Error deleting user: #{error}"
      assert response.code.to_i == 200, "Unable to delete user: HTTP response from API should have code 200, was #{response.code} #{error} #{body}"
      assert(response = JSON.parse(body), 'Delete response should be JSON')
      assert(response["success"], 'Deleting user should be a success')
    end
  end

  def assert_delete_srp_user(user)
    if user && user.ok && user.id && user.session_token && !user.deleted
      url = api_url("users/#{user.id}.json")
      params = {:identities => 'destroy'}
      user.deleted = true
      delete(url, params, api_options(:auth => user.session_token)) do |body, response, error|
        assert error.nil?, "Error deleting user: #{error}"
        assert response.code.to_i == 200, "Unable to delete user: HTTP response from API should have code 200, was #{response.code} #{error} #{body}"
        assert(response = JSON.parse(body), 'Delete response should be JSON')
        assert(response["success"], 'Deleting user should be a success')
      end
    end
  end


end
