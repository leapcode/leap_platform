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
    url = couchdb_backend_url("/nodes/_all_docs")
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

  def test_03_replica_membership
    url = couchdb_url("/_membership")
    assert_get(url) do |body|
      response = JSON.parse(body)
      nodes_configured_but_not_available = response['cluster_nodes'] - response['all_nodes']
      nodes_available_but_not_configured = response['cluster_nodes'] - response['all_nodes']
      if nodes_configured_but_not_available.any?
        warn "These nodes are configured but not available:", nodes_configured_but_not_available
      end
      if nodes_available_but_not_configured.any?
        warn "These nodes are available but not configured:", nodes_available_but_not_configured
      end
      if response['cluster_nodes'] == response['all_nodes']
        pass
      end
    end
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

  def couchdb_backend_url(path="")
    couchdb_url(path, "5986") # TODO: admin port is hardcoded for now but should be configurable.
  end

end
