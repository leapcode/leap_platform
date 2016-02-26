raise SkipTest unless service?(:mx)

require 'json'

class Mx < LeapTest
  depends_on "Network"

  def setup
  end

  def test_01_Can_contact_couchdb?
    dbs = ["identities"]
    dbs.each do |db_name|
      couchdb_urls("/"+db_name, url_options).each do |url|
        assert_get(url) do |body|
          assert response = JSON.parse(body)
          assert_equal db_name, response['db_name']
        end
      end
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

  def test_03_Are_MX_daemons_running?
    assert_running '.*/usr/bin/twistd.*mx.tac'
    assert_running '^/usr/lib/postfix/master$'
    assert_running '^/usr/sbin/postfwd'
    assert_running 'postfwd2::cache$'
    assert_running 'postfwd2::policy$'
    assert_running '^/usr/sbin/unbound$'
    if File.exists?('/var/lib/clamav/daily.cld')
      assert_running '^/usr/sbin/clamd'
      assert_running '^/usr/sbin/clamav-milter'
      assert_running '^/usr/bin/freshclam'
    else
      skip "The clamav signature file (/var/lib/clamav/daily.cld) has yet to be downloaded, so clamd is not running."
    end
    pass
  end

  private

  def url_options
    {
      :username => property('couchdb_leap_mx_user.username'),
      :password => property('couchdb_leap_mx_user.password')
    }
  end

end
