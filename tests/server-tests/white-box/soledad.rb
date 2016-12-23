raise SkipTest unless service?(:soledad)

require 'json'

class Soledad < LeapTest
  depends_on "Network"
  depends_on "CouchDB" if service?(:couchdb)

  def setup
  end

  def test_00_Is_Soledad_running?
    assert_running '/usr/bin/python /usr/bin/twistd --uid=soledad --gid=soledad --pidfile=/var/run/soledad.pid --syslog --prefix=soledad-server web --class=leap.soledad.server.resource.SoledadResource.*'
    pass
  end

end
