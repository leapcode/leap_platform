raise SkipTest unless $node["services"].include?("couchdb")

require 'json'

class TestCouchdb < LeapTest

  def setup
  end

  #
  # check to make sure we can get welcome response from local couchdb
  #
  def test_01_is_running
    assert_get(couchdb_url) do |body|
      assert_match /"couchdb":"Welcome"/, body, "Could not get welcome message from #{couchdb_url}. Probably couchdb is not running."
    end
    pass
  end

  #
  # compare the configured nodes to the nodes that are actually listed in bigcouch
  #
  def test_02_nodes_are_in_replication_database
    url = couchdb_admin_url("/nodes/_all_docs")
    neighbors = assert_property('couch.bigcouch.neighbors')
    neighbors << assert_property('domain.full')
    neighbors.sort!
    assert_get(url) do |body|
      response = JSON.parse(body)
      nodes_in_db = response['rows'].collect{|row| row['id'].sub(/^bigcouch@/, '')}.sort
      assert_equal neighbors, nodes_in_db, "The couchdb replication node list is wrong (/nodes/_all_docs)"
    end
    pass
  end

  private

  def couchdb_url(path="", port=nil)
    @port ||= begin
      assert_property 'couch.port'
      $node['couch']['port']
    end
    @password ||= begin
      assert_property 'couch.users.admin.password'
      $node['couch']['users']['admin']['password']
    end
    "http://admin:#{@password}@localhost:#{port || @port}#{path}"
  end

  def couchdb_admin_url(path="")
    couchdb_url(path, "5986") # admin port is hardcoded for now.
  end

end
