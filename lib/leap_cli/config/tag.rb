#
#
# A class for node services or node tags.
#
#

module LeapCli; module Config

  class Tag < Object
    attr_reader :node_list

    def initialize(environment=nil)
      super(environment)
      @node_list = Config::ObjectList.new
    end

    # don't copy the node list pointer when this object is dup'ed.
    def initialize_copy(orig)
      super
      @node_list = Config::ObjectList.new
    end

  end

end; end
