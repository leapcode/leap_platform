#
# Configuration for a 'node' (a server in the provider's infrastructure)
#

require 'ipaddr'

module LeapCli; module Config

  class Node < Object
    attr_accessor :file_paths

    def initialize(environment=nil)
      super(environment)
      @node = self
      @file_paths = []
    end

    #
    # returns true if this node has an ip address in the range of the vagrant network
    #
    def vagrant?
      begin
        vagrant_range = IPAddr.new LeapCli.leapfile.vagrant_network
      rescue ArgumentError => exc
        Util::bail! { Util::log :invalid, "ip address '#{@node.ip_address}' vagrant.network" }
      end

      begin
        ip_address = IPAddr.new @node.get('ip_address')
      rescue ArgumentError => exc
        Util::log :warning, "invalid ip address '#{@node.get('ip_address')}' for node '#{@node.name}'"
      end
      return vagrant_range.include?(ip_address)
    end

    #
    # Return a hash table representation of ourselves, with the key equal to the @node.name,
    # and the value equal to the fields specified in *keys.
    #
    # Also, the result is flattened to a single hash, so a key of 'a.b' becomes 'a_b'
    #
    # compare to Object#pick(*keys). This method is the sames as Config::ObjectList#pick_fields,
    # but works on a single node.
    #
    # Example:
    #
    #  node.pick('domain.internal') =>
    #
    #    {
    #      'node1': {
    #        'domain_internal': 'node1.example.i'
    #      }
    #    }
    #
    def pick_fields(*keys)
      {@node.name => self.pick(*keys)}
    end

    #
    # can be overridden by the platform.
    # returns a list of node names that should be tested before this node
    #
    def test_dependencies
      []
    end

    # returns a string list of supported ssh host key algorithms for this node.
    # or an empty string if it could not be determined
    def supported_ssh_host_key_algorithms
      require 'leap_cli/ssh'
      @host_key_algo ||= LeapCli::SSH::Key.supported_host_key_algorithms(
        Util.read_file([:node_ssh_pub_key, @node.name])
      )
    end

  end

end; end
