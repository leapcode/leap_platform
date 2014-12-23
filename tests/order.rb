class LeapCli::Config::Node
  #
  # returns a list of node names that should be tested before this node.
  # make sure to not return ourselves (please no dependency loops!).
  #
  # NOTE: this method determines the order that nodes are tested in. To specify
  # the order of tests on a particular node, each test can call class method
  # LeapTest.depends_on().
  #
  def test_dependencies
    dependents = LeapCli::Config::ObjectList.new
    unless services.include?('couchdb')
      if services.include?('webapp') || services.include?('mx') || services.include?('soledad')
        dependents.merge! nodes_like_me[:services => 'couchdb']
      end
    end
    dependents.keys.delete_if {|name| self.name == name}
  end
end