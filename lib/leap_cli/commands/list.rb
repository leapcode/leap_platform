require 'command_line_reporter'

module LeapCli; module Commands

  desc 'List nodes and their classifications'
  long_desc 'Prints out a listing of nodes, services, or tags. ' +
            'If present, the FILTER can be a list of names of nodes, services, or tags. ' +
            'If the name is prefixed with +, this acts like an AND condition. ' +
            "For example:\n\n" +
            "`leap list node1 node2` matches all nodes named \"node1\" OR \"node2\"\n\n" +
            "`leap list openvpn +local` matches all nodes with service \"openvpn\" AND tag \"local\""

  arg_name 'FILTER', :optional => true
  command [:list,:ls] do |c|
    c.flag 'print', :desc => 'What attributes to print (optional)'
    c.switch 'disabled', :desc => 'Include disabled nodes in the list.', :negatable => false
    c.action do |global_options,options,args|
      # don't rely on default manager(), because we want to pass custom options to load()
      manager = LeapCli::Config::Manager.new
      if global_options[:color]
        colors = ['cyan', 'white']
      else
        colors = [nil, nil]
      end
      puts
      manager.load(:include_disabled => options['disabled'], :continue_on_error => true)
      if options['print']
        print_node_properties(manager.filter(args), options['print'])
      else
        if args.any?
          NodeTable.new(manager.filter(args), colors).run
        else
          environment = LeapCli.leapfile.environment || '_all_'
          TagTable.new('SERVICES', manager.env(environment).services, colors).run
          TagTable.new('TAGS', manager.env(environment).tags, colors).run
          NodeTable.new(manager.filter(), colors).run
        end
      end
    end
  end

  private

  def self.print_node_properties(nodes, properties)
    properties = properties.split(',')
    max_width = nodes.keys.inject(0) {|max,i| [i.size,max].max}
    nodes.each_node do |node|
      value = properties.collect{|prop|
        prop_value = node[prop]
        if prop_value.nil?
          "null"
        elsif prop_value == ""
          "empty"
        elsif prop_value.is_a? LeapCli::Config::Object
          node[prop].dump_json(:compact) # TODO: add option of getting pre-evaluation values.
        else
          prop_value.to_s
        end
      }.join(', ')
      printf("%#{max_width}s  %s\n", node.name, value)
    end
    puts
  end

  class TagTable
    include CommandLineReporter
    def initialize(heading, tag_list, colors)
      @heading = heading
      @tag_list = tag_list
      @colors = colors
    end
    def run
      tags = @tag_list.keys.select{|tag| tag !~ /^_/}.sort # sorted list of tags, excluding _partials
      max_width = [20, (tags+[@heading]).inject(0) {|max,i| [i.size,max].max}].max
      table :border => false do
        row :color => @colors[0]  do
          column @heading, :align => 'right', :width => max_width
          column "NODES", :width => HighLine::SystemExtensions.terminal_size.first - max_width - 2, :padding => 2
        end
        tags.each do |tag|
          next if @tag_list[tag].node_list.empty?
          row :color => @colors[1] do
            column tag
            column @tag_list[tag].node_list.keys.sort.join(', ')
          end
        end
      end
      vertical_spacing
    end
  end

  #
  # might be handy: HighLine::SystemExtensions.terminal_size.first
  #
  class NodeTable
    include CommandLineReporter
    def initialize(node_list, colors)
      @node_list = node_list
      @colors = colors
    end
    def run
      rows = @node_list.keys.sort.collect do |node_name|
        [node_name, @node_list[node_name].services.sort.join(', '), @node_list[node_name].tags.sort.join(', ')]
      end
      unless rows.any?
        puts Paint["no results", :red]
        puts
        return
      end
      padding = 2
      max_node_width    = [20, (rows.map{|i|i[0]} + ["NODES"]   ).inject(0) {|max,i| [i.size,max].max}].max
      max_service_width = (rows.map{|i|i[1]} + ["SERVICES"]).inject(0) {|max,i| [i.size+padding+padding,max].max}
      max_tag_width     = (rows.map{|i|i[2]} + ["TAGS"]    ).inject(0) {|max,i| [i.size,max].max}
      table :border => false do
        row :color => @colors[0]  do
          column "NODES", :align => 'right', :width => max_node_width
          column "SERVICES", :width => max_service_width, :padding => 2
          column "TAGS", :width => max_tag_width
        end
        rows.each do |r|
          row :color => @colors[1] do
            column r[0]
            column r[1]
            column r[2]
          end
        end
      end
      vertical_spacing
    end
  end

end; end
