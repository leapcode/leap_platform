raise SkipTest unless service?(:soledad)

require 'json'

class Soledad < LeapTest
  depends_on "Network"
  depends_on "CouchDB" if service?(:couchdb)

  def setup
  end

  def test_00_Is_Soledad_running?
    assert_running service: 'soledad-server'
    pass
  end

end
