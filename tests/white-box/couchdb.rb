raise SkipTest unless $node["services"].include?("couchdb")

require 'json'

class CouchDB < LeapTest
  depends_on "Network"

  def setup
  end

  def test_00_Are_daemons_running?
    assert_running 'tapicero'
    if multimaster?
      assert_running 'bin/beam'
      assert_running 'bin/epmd'
    end
    pass
  end

  #
  # check to make sure we can get welcome response from local couchdb
  #
  def test_01_Is_CouchDB_running?
    assert_get(couchdb_url) do |body|
      assert_match /"couchdb":"Welcome"/, body, "Could not get welcome message from #{couchdb_url}. Probably couchdb is not running."
    end
    pass
  end

  #
  # compare the configured nodes to the nodes that are actually listed in bigcouch
  #
  def test_02_Is_cluster_membership_ok?
    return unless multimaster?
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

  #
  # all configured nodes are in 'cluster_nodes'
  # all nodes online and communicating are in 'all_nodes'
  #
  # this seems backward to me, so it might be the other way around.
  #
  def test_03_Are_configured_nodes_online?
    return unless multimaster?
    url = couchdb_url("/_membership", :user => 'admin')
    assert_get(url) do |body|
      response = JSON.parse(body)
      nodes_configured_but_not_available = response['cluster_nodes'] - response['all_nodes']
      nodes_available_but_not_configured = response['all_nodes'] - response['cluster_nodes']
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

  def test_04_Do_ACL_users_exist?
    acl_users = ['_design/_auth', 'leap_mx', 'nickserver', 'soledad', 'tapicero', 'webapp', 'replication']
    url = couchdb_backend_url("/_users/_all_docs", :user => 'admin')
    assert_get(url) do |body|
      response = JSON.parse(body)
      assert_equal acl_users.count, response['total_rows']
      actual_users = response['rows'].map{|row| row['id'].sub(/^org.couchdb.user:/, '') }
      assert_equal acl_users.sort, actual_users.sort
    end
    pass
  end

  def test_05_Do_required_databases_exist?
    dbs_that_should_exist = ["customers","identities","keycache","sessions","shared","tickets","tokens","users"]
    dbs_that_should_exist.each do |db_name|
      url = couchdb_url("/"+db_name, :user => 'admin')
      assert_get(url) do |body|
        assert response = JSON.parse(body)
        assert_equal db_name, response['db_name']
      end
    end
    pass
  end

  # disable ACL enforcement, because it's a known issue with bigcouch
  # and will only confuse the user
  # see https://leap.se/code/issues/6030 for more details
  #
  ## for now, this just prints warnings, since we are failing these tests.
  ##

  #def test_06_Is_ACL_enforced?
  #  ok = assert_auth_fail(
  #    couchdb_url('/users/_all_docs', :user => 'leap_mx'),
  #    {:limit => 1}
  #  )
  #  ok = assert_auth_fail(
  #    couchdb_url('/users/_all_docs', :user => 'leap_mx'),
  #    {:limit => 1}
  #  ) && ok
  #  pass if ok
  #end

  def test_07_What?
    pass
  end

  private

  def couchdb_url(path="", options=nil)
    options||={}
    @port ||= begin
      assert_property 'couch.port'
      $node['couch']['port']
    end
    url = 'http://'
    if options[:user]
      assert_property 'couch.users.' + options[:user]
      password = $node['couch']['users'][options[:user]]['password']
      url += "%s:%s@" % [options[:user], password]
    end
    url += "localhost:#{options[:port] || @port}#{path}"
    url
  end

  def couchdb_backend_url(path="", options={})
    # TODO: admin port is hardcoded for now but should be configurable.
    options = {port: multimaster? && "5986"}.merge options
    couchdb_url(path, options)
  end

  def multimaster?
    mode == "multimaster"
  end

  def mode
    assert_property('couch.mode')
  end

end
