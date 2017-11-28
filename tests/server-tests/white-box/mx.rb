raise SkipTest unless service?(:mx)

require 'date'
require 'json'
require 'net/smtp'

class Mx < LeapTest
  depends_on "Network"
  depends_on "Webapp" if service?(:webapp)

  def setup
  end

  def test_01_Can_contact_couchdb?
    dbs = ["identities"]
    dbs.each do |db_name|
      couchdb_urls("/"+db_name, couch_url_options).each do |url|
        assert_get(url) do |body|
          assert response = JSON.parse(body)
          assert_equal db_name, response['db_name']
        end
      end
    end
    pass
  end

  #
  # this test picks a random identity document, then queries
  # using the by_address view for that same document again.
  #
  def test_03_Can_query_identities_db?
    ident = pick_random_identity
    address = ident['address']
    url_base = %(/identities/_design/Identity/_view/by_address)
    params = %(?include_docs=true&reduce=false&startkey="#{address}"&endkey="#{address}")
    assert_get(couchdb_url(url_base+params, couch_url_options)) do |body|
      assert response = JSON.parse(body)
      assert record = response['rows'].first
      assert_equal address, record['doc']['address']
      pass
    end
  end

  def test_04_Are_MX_daemons_running?
    assert_running match: '.*/usr/bin/twistd.*mx.tac'
    assert_running match: '^/usr/lib/postfix/master$'
    assert_running match: '^/usr/sbin/postfwd'
    assert_running match: 'postfwd2::cache$'
    assert_running match: 'postfwd2::policy$'
    assert_running match: '^/usr/sbin/unbound'
    assert_running match: '^/usr/bin/freshclam'
    assert_running match: '^/usr/sbin/opendkim'
    if Dir.glob("/var/lib/clamav/main.{c[vl]d,inc}").size > 0 and Dir.glob("/var/lib/clamav/daily.{c[vl]d,inc}").size > 0
      assert_running match: '^/usr/sbin/clamd'
      assert_running match: '^/usr/sbin/clamav-milter'
      pass
    else
      skip "Downloading the clamav signature files (/var/lib/clamav/{daily,main}.{c[vl]d,inc}) is still in progress, so clamd is not running."
    end
  end

  #
  # TODO: test to make sure postmap returned the right result
  #
  def test_05_Can_postfix_query_leapmx?
    ident = pick_random_identity(10, :with_public_key => true)
    address = ident["address"]

    #
    # virtual alias map:
    #
    #   user@domain => 41c29a80a44f4775513c64ac9cab91b9@deliver.local
    #
    assert_run("postmap -v -q \"#{address}\" tcp:localhost:4242")

    #
    # recipient access map:
    #
    #   user@domain => [OK|REJECT|TEMP_FAIL]
    #
    # This map is queried by the mail server before delivery to the mail spool
    # directory, and should check if the address is able to receive messages.
    # Examples of reasons for denying delivery would be that the user is out of
    # quota, is user, or have no pgp public key in the server.
    #
    # NOTE: in the future, when we support quota, we need to make sure that
    # we don't randomly pick a user for this test that happens to be over quota.
    #
    assert_run("postmap -v -q \"#{address}\" tcp:localhost:2244")

    #
    # certificate validity map:
    #
    #  fa:2a:70:1f:d8:16:4e:1a:3b:15:c1:67:00:f0 => [200|500]
    #
    # Determines whether a particular SMTP client cert is authorized
    # to relay mail, based on the fingerprint.
    #
    if ident["cert_fingerprints"]
      not_expired = ident["cert_fingerprints"].select {|key, value|
        Time.now.utc < DateTime.strptime("2016-01-03", "%F").to_time.utc
      }
      if not_expired.any?
        fingerprint = not_expired.first
        assert_run("postmap -v -q #{fingerprint} tcp:localhost:2424")
      end
    end

    pass
  end

  #
  # The email sent by this test might get bounced back.
  # In this case, the test will pass, but the bounce message will
  # get sent to root, so the sysadmin will still figure out pretty
  # quickly that something is wrong.
  #
  def test_05_Can_deliver_email?
    if pgrep('^/usr/sbin/clamd').empty? || pgrep('^/usr/sbin/clamav-milter').empty?
      skip "Mail delivery is being deferred because clamav daemon is not running"
    else
      addr = [TEST_EMAIL_USER, property('domain.full_suffix')].join('@')
      bad_addr = [TEST_BAD_USER, property('domain.full_suffix')].join('@')

      assert !identity_exists?(bad_addr), "the address #{bad_addr} must not exist."
      if !identity_exists?(addr)
        user = assert_create_user(TEST_EMAIL_USER, :monitor)
        upload_public_key(user.id, TEST_EMAIL_PUBLIC_KEY)
      end
      assert identity_exists?(addr), "The identity #{addr} should have been created, but it doesn't exist yet."
      assert_send_email(addr)
      assert_raises(Net::SMTPError) do
        send_email(bad_addr)
      end
      pass
    end
  end

  private

  def couch_url_options
    {
      :username => property('couchdb_leap_mx_user.username'),
      :password => property('couchdb_leap_mx_user.password')
    }
  end

  #
  # returns a random identity record that also has valid address
  # and destination fields.
  #
  # options:
  #
  # * :with_public_key -- searches only for identities with public keys
  #
  # note to self: for debugging, here is the curl you want:
  # curl --netrc "127.0.0.1:5984/identities/_design/Identity/_view/by_address?startkey=\"xxxx@leap.se\"&endkey=\"xxxx@leap.se\"&reduce=false&include_docs=true"
  #
  def pick_random_identity(tries=5, options={})
    assert_get(couchdb_url("/identities", couch_url_options)) do |body|
      assert response = JSON.parse(body)
      doc_count = response['doc_count'].to_i
      if doc_count <= 1
        # the design document counts as one document.
        skip "There are no identity documents yet."
      else
        # try repeatedly to get a valid doc
        for i in 1..tries
          offset    = rand(doc_count) # pick a random document
          url = couchdb_url("/identities/_all_docs?include_docs=true&limit=1&skip=#{offset}", couch_url_options)
          assert_get(url) do |body|
            assert response = JSON.parse(body)
            record = response['rows'].first
            if record['id'] =~ /_design/
              next
            elsif record['doc'] && record['doc']['address']
              next if record['doc']['destination'].nil? || record['doc']['destination'].empty?
              next if options[:with_public_key] && !record_has_key?(record)
              return record['doc']
            else
              fail "Identity document #{record['id']} is missing an address field. #{record['doc'].inspect}"
            end
          end
        end
        if options[:with_public_key]
          skip "Could not find an Identity document with a public key for testing."
        else
          fail "Failed to find a valid Identity document (with address and destination)."
        end
      end
    end
  end

  def record_has_key?(record)
    !record['doc']['keys'].nil? &&
    !record['doc']['keys'].empty? &&
    !record['doc']['keys']['pgp'].nil? &&
    !record['doc']['keys']['pgp'].empty?
  end

  TEST_EMAIL_PUBLIC_KEY=<<HERE
-----BEGIN PGP PUBLIC KEY BLOCK-----
mI0EVvzIKQEEAN4f8FOGntJGTTD+fFUQS6y/ihn6tYLtyGZZbCOd0t/9kHt/raoR
xEUks8rCOPMqHX+yeHsvDBtDyZYTvyhtfuWrBUbYGW+QZ4Pdvo+7NyLHPW0dKsCB
Czrx7pxqpq1oq+LpUFqpSfjJTfYaGVDNXrPK144a7Rox2+MCbgq3twnFABEBAAG0
EiA8dGVzdF91c2VyX2VtYWlsPoi4BBMBAgAiBQJW/MgpAhsvBgsJCAcDAgYVCAIJ
CgsEFgIDAQIeAQIXgAAKCRAqYf65XmeSk0orBADUXjEiGnjzyBpXqaiVmJr4MyfP
IfKTK4a+4qvR+2fseD7hteF98m26i1YRI5omLp4/MnxGSpgKFKIuWIdkEiLg7IJc
pFZVdoDVufEtzbj9gmOHlnteksbCtuESyB0Hytsba4uS9afcTJdGiPNMHeniI/SY
UKcCcIrQmpNIoOA5OLiNBFb8yCkBBAC+WMUQ+FC6GQ+pyaWlwTRsBAT4+Tp8w9jD
7PK4xeEmVZDirP0VkW18UeQEueWJ63ia7wIGf1WyVH1tbvgVyRLsjT2cpKo8c6Ok
NkhfGfjTnUJPeBNy8734UDIdqZLXJl0z6Z1R0CfOjBqvV25kWUvMkz/NEgZBhE+c
m3JuZy1k7QARAQABiQE9BBgBAgAJBQJW/MgpAhsuAKgJECph/rleZ5KTnSAEGQEC
AAYFAlb8yCkACgkQsJSYitQUOv4w1wQAn3atI5EsmRyw6iC6UVWWJv/lKi1Priyt
DsrdH5xUmHUgp6VU8Pw9Y6G+sv50KLfbVQ1l+8/3B71TjadsOxh+PBPsEyYpK6WX
TVGy44IDvFWGyOod8tmfcFN9IpU5DmSk/vny9G7RK/nbnta2VnfZOzwm5i3cNkPr
FGPL1z0K3qs0VwP+M7BXdqBRSFDDBpG1J0TrZioEjvKeOsT/Ul8mbVt7HQpcN93I
wTO4uky0Woy2nb7SbTQw6wOpU54u7+5dSQ03ltUHg1owy6Y3CMOeFL+e9ALpAZAU
aMwY7zMFhqlPVZZMfdMLRsdLin67RIM+OJ6A925AM52bEQT1YwkQlP4mvQY=
=qclE
-----END PGP PUBLIC KEY BLOCK-----
HERE

  TEST_EMAIL_PRIVATE_KEY = <<HERE
-----BEGIN PGP PRIVATE KEY BLOCK-----
lQHYBFb8yCkBBADeH/BThp7SRk0w/nxVEEusv4oZ+rWC7chmWWwjndLf/ZB7f62q
EcRFJLPKwjjzKh1/snh7LwwbQ8mWE78obX7lqwVG2BlvkGeD3b6Puzcixz1tHSrA
gQs68e6caqataKvi6VBaqUn4yU32GhlQzV6zyteOGu0aMdvjAm4Kt7cJxQARAQAB
AAP8DTFfcE6UG1AioJDU6KZ9oCaGONHLuxmNaArSofDrR/ODA9rLAUlp22N5LEdJ
46NyOhXrEwHx2aK2k+vbVDbgrP4ZTH7GxIK/2KzmH4zX0fWUNsaRy94Q12lJegXH
sH2Im8Jjxu16YwGgFNTX1fCPqLB6WdQpf1796s6+/3PnCDcCAOXTCul3N7V5Yl+9
N2Anupn+qNDXKT/kiKIZLHsMbo7EriGWReG3lLj1cOJPC6Nf0uOEri4ErSjFEadR
F2TNITsCAPdsZjc5RGppUXyBfxhQkAnZ0r+UT2meCH3g3EVh3W9SBrXNhwipNpW3
bPzRjUCDtmA8EOvd93oPCZv4/tb50P8B/jC+QIZ3GncP1CFPSVDoIZ7OUU5M1330
DP77vG1GxeQvYO/hlxL5/KdtTR6m5zlIuooDxUaNJz1w5/oVjlG3NZKpl7QSIDx0
ZXN0X3VzZXJfZW1haWw+iLgEEwECACIFAlb8yCkCGy8GCwkIBwMCBhUIAgkKCwQW
AgMBAh4BAheAAAoJECph/rleZ5KTSisEANReMSIaePPIGlepqJWYmvgzJ88h8pMr
hr7iq9H7Z+x4PuG14X3ybbqLVhEjmiYunj8yfEZKmAoUoi5Yh2QSIuDsglykVlV2
gNW58S3NuP2CY4eWe16SxsK24RLIHQfK2xtri5L1p9xMl0aI80wd6eIj9JhQpwJw
itCak0ig4Dk4nQHYBFb8yCkBBAC+WMUQ+FC6GQ+pyaWlwTRsBAT4+Tp8w9jD7PK4
xeEmVZDirP0VkW18UeQEueWJ63ia7wIGf1WyVH1tbvgVyRLsjT2cpKo8c6OkNkhf
GfjTnUJPeBNy8734UDIdqZLXJl0z6Z1R0CfOjBqvV25kWUvMkz/NEgZBhE+cm3Ju
Zy1k7QARAQABAAP9HrUaGvdpqTwVx3cHyXUhId6GzCuuKyaP4mZoGeBCcaQS2vQR
YtiykwBwX/AlfwSFJmmHKB6EErWIA+QyaEFR/fO56cHD2TY3Ql0BGcuHIx3+9pkp
biPBZdiiGz7oa6k6GWsbKSksqwV8poSXV7qbn+Bjm2xCM4VnjNZIrFtL7fkCAMOf
e9yHBFoXfc175bkNXEUXrNS34kv2ODAlx6KyY+PS77D+nprpHpGCnLn77G+xH1Xi
qvX1Dr/iSQU5Tzsd+tcCAPkYZulaC/9itwme7wIT3ur+mdqMHymsCzv9193iLgjJ
9t7fARo18yB845hI9Xv7TwRcoyuSpfvuM05rCMRzydsCAOI1MZeKtZSogXVa9QTX
sVGZeCkrujSVOgsA3w48OLc2OrwZskDfx5QHfeJnumjQLut5qsnZ+1onj9P2dGdn
JaChe4kBPQQYAQIACQUCVvzIKQIbLgCoCRAqYf65XmeSk50gBBkBAgAGBQJW/Mgp
AAoJELCUmIrUFDr+MNcEAJ92rSORLJkcsOogulFVlib/5SotT64srQ7K3R+cVJh1
IKelVPD8PWOhvrL+dCi321UNZfvP9we9U42nbDsYfjwT7BMmKSull01RsuOCA7xV
hsjqHfLZn3BTfSKVOQ5kpP758vRu0Sv5257WtlZ32Ts8JuYt3DZD6xRjy9c9Ct6r
NFcD/jOwV3agUUhQwwaRtSdE62YqBI7ynjrE/1JfJm1bex0KXDfdyMEzuLpMtFqM
tp2+0m00MOsDqVOeLu/uXUkNN5bVB4NaMMumNwjDnhS/nvQC6QGQFGjMGO8zBYap
T1WWTH3TC0bHS4p+u0SDPjiegPduQDOdmxEE9WMJEJT+Jr0G
=hvJM
-----END PGP PRIVATE KEY BLOCK-----
HERE

end
