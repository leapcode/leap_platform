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

  #
  # this test picks a random identity document, then queries
  # using the by_address view for that same document again.
  #
  def test_03_Can_query_identities_db?
    assert_get(couchdb_url("/identities", url_options)) do |body|
      assert response = JSON.parse(body)
      doc_count = response['doc_count'].to_i
      if doc_count < 1
        skip "There are no identity records yet."
      else
        offset = rand(doc_count) # pick a random document
        count_url = couchdb_url("/identities/_all_docs?include_docs=true&limit=1&skip=#{offset}", url_options)
        assert_get(count_url) do |body|
          assert response = JSON.parse(body)
          record = response['rows'].first
          address = record['doc']['address']
          assert address, "address should not be empty"
          url_base = %(/identities/_design/Identity/_view/by_address)
          params = %(?include_docs=true&reduce=false&startkey="#{address}"&endkey="#{address}")
          assert_get(couchdb_url(url_base+params, url_options)) do |body|
            assert response = JSON.parse(body)
            assert record = response['rows'].first
            assert_equal address, record['doc']['address']
            pass
          end
        end
      end
    end
  end

  def test_03_Are_MX_daemons_running?
    assert_running '.*/usr/bin/twistd.*mx.tac'
    assert_running '^/usr/lib/postfix/master$'
    assert_running '^/usr/sbin/postfwd'
    assert_running 'postfwd2::cache$'
    assert_running 'postfwd2::policy$'
    assert_running '^/usr/sbin/unbound$'
    assert_running '^/usr/bin/freshclam'
    assert_running '^/usr/sbin/opendkim'
    if Dir.glob("/var/lib/clamav/main.{c[vl]d,inc}").size > 0 and Dir.glob("/var/lib/clamav/daily.{c[vl]d,inc}").size > 0
      assert_running '^/usr/sbin/clamd'
      assert_running '^/usr/sbin/clamav-milter'
    else
      skip "Downloading the clamav signature files (/var/lib/clamav/{daily,main}.{c[vl]d,inc}) is still in progress, so clamd is not running.\nDon't worry, mail delivery will work without clamav. The download should finish soon."
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
