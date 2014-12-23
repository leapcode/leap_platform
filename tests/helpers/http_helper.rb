require 'net/http'

class LeapTest

  #
  # In order to easily provide detailed error messages, it is useful
  # to append a memo to a url string that details what this url is for
  # (e.g. stunnel, haproxy, etc).
  #
  # So, the url happens to be a UrlString, the memo field is used
  # if there is an error in assert_get.
  #
  class URLString < String
    attr_accessor :memo
  end

  #
  # aliases for http_send()
  #
  def get(url, params=nil, options=nil, &block)
    http_send("GET", url, params, options, &block)
  end
  def delete(url, params=nil, options=nil, &block)
    http_send("DELETE", url, params, options, &block)
  end
  def post(url, params=nil, options=nil, &block)
    http_send("POST", url, params, options, &block)
  end
  def put(url, params=nil, options=nil, &block)
    http_send("PUT", url, params, options, &block)
  end

  #
  # send a GET, DELETE, POST, or PUT
  # yields |body, response, error|
  #
  def http_send(method, url, params=nil, options=nil)
    options ||= {}
    response = nil

    # build uri
    uri = URI(url)
    if params && (method == 'GET' || method == 'DELETE')
      uri.query = URI.encode_www_form(params)
    end

    # build http
    http = Net::HTTP.new uri.host, uri.port
    if uri.scheme == 'https'
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.use_ssl = true
    end

    # build request
    request = build_request(method, uri, params, options)

    # make http request
    http.start do |agent|
      response = agent.request(request)
      yield response.body, response, nil
    end
  rescue => exc
    yield nil, response, exc
  end

  #
  # Aliases for assert_http_send()
  #
  def assert_get(url, params=nil, options=nil, &block)
    assert_http_send("GET", url, params, options, &block)
  end
  def assert_delete(url, params=nil, options=nil, &block)
    assert_http_send("DELETE", url, params, options, &block)
  end
  def assert_post(url, params=nil, options=nil, &block)
    assert_http_send("POST", url, params, options, &block)
  end
  def assert_put(url, params=nil, options=nil, &block)
    assert_http_send("PUT", url, params, options, &block)
  end

  #
  # calls http_send, yielding results if successful or failing with
  # descriptive infor otherwise.
  #
  def assert_http_send(method, url, params=nil, options=nil, &block)
    options ||= {}
    error_msg = options[:error_msg] || (url.respond_to?(:memo) ? url.memo : nil)
    http_send(method, url, params, options) do |body, response, error|
      if body && response && response.code.to_i >= 200 && response.code.to_i < 300
        if block
          yield(body) if block.arity == 1
          yield(response, body) if block.arity == 2
        end
      elsif response
        fail ["Expected a 200 status code from #{method} #{url}, but got #{response.code} instead.", error_msg, body].compact.join("\n")
      else
        fail ["Expected a response from #{method} #{url}, but got \"#{error}\" instead.", error_msg, body].compact.join("\n"), error
      end
    end
  end

  #
  # only a warning for now, should be a failure in the future
  #
  def assert_auth_fail(url, params)
    uri = URI(url)
    get(url, params) do |body, response, error|
      unless response.code.to_s == "401"
        warn "Expected a '401 Unauthorized' response, but got #{response.code} instead (GET #{uri.request_uri} with username '#{uri.user}')."
        return false
      end
    end
    true
  end

  private

  def build_request(method, uri, params, options)
    request = case method
      when "GET"    then Net::HTTP::Get.new(uri.request_uri)
      when "DELETE" then Net::HTTP::Delete.new(uri.request_uri)
      when "POST"   then Net::HTTP::Post.new(uri.request_uri)
      when "PUT"    then Net::HTTP::Put.new(uri.request_uri)
    end
    if uri.user
      request.basic_auth uri.user, uri.password
    end
    if params && (method == 'POST' || method == 'PUT')
      if options[:format] == :json || options[:format] == 'json'
        request["Content-Type"] = "application/json"
        request.body = params.to_json
      else
        request.set_form_data(params) if params
      end
    end
    if options[:headers]
      options[:headers].each do |key, value|
        request[key] = value
      end
    end
    request
  end

end