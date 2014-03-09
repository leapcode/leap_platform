class LeapCli::Config::Node
  #
  # returns a list of node names that should be tested before this node.
  # make sure to not return ourselves (please no dependency loops!).
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