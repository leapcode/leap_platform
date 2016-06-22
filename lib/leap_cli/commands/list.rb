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
        colors = [:cyan, nil]
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
          node[prop].dump_json(:format => :compact) # TODO: add option of getting pre-evaluation values.
        else
          prop_value.to_s
        end
      }.join(', ')
      printf("%#{max_width}s  %s\n", node.name, value)
    end
    puts
  end

  class Table
    def table
      @rows = []
      @row_options = []
      @column_widths = [20] # first column at least 20
      @column_options = []
      @current_row = 0
      @current_column = 0
      yield
    end

    def row(options=nil)
      @current_column = 0
      @row_options[@current_row] ||= options
      yield
      @current_row += 1
    end

    def column(str, options=nil)
      @rows[@current_row] ||= []
      @rows[@current_row][@current_column] = str
      @column_widths[@current_column] = [str.length, @column_widths[@current_column]||0].max
      @column_options[@current_column] ||= options
      @current_column += 1
    end

    def draw_table
      @rows.each_with_index do |row, i|
        color = (@row_options[i]||{})[:color]
        row.each_with_index do |column, j|
          align = (@column_options[j]||{})[:align] || "left"
          width = @column_widths[j]
          if color
            str = LeapCli.logger.colorize(column, color)
            extra_width = str.length - column.length
          else
            str = column
            extra_width = 0
          end
          if align == "right"
            printf "  %#{width+extra_width}s" % str
          else
            printf "  %-#{width+extra_width}s" % str
          end
        end
        puts
      end
      puts
    end
  end

  class TagTable < Table
    def initialize(heading, tag_list, colors)
      @heading = heading
      @tag_list = tag_list
      @colors = colors
    end
    def run
      tags = @tag_list.keys.select{|tag| tag !~ /^_/}.sort # sorted list of tags, excluding _partials
      table do
        row(color: @colors[0]) do
          column @heading, align: 'right'
          column "NODES"
        end
        tags.each do |tag|
          next if @tag_list[tag].node_list.empty?
          row(color: @colors[1]) do
            column tag
            column @tag_list[tag].node_list.keys.sort.join(', ')
          end
        end
      end
      draw_table
    end
  end

  class NodeTable < Table
    def initialize(node_list, colors)
      @node_list = node_list
      @colors = colors
    end
    def run
      rows = @node_list.keys.sort.collect do |node_name|
        [node_name, @node_list[node_name].services.sort.join(', '), @node_list[node_name].tags.sort.join(', ')]
      end
      unless rows.any?
        puts " = " + LeapCli.logger.colorize("no results", :red)
        puts
        return
      end
      table do
        row(color: @colors[0]) do
          column "NODES", align: 'right'
          column "SERVICES"
          column "TAGS"
        end
        rows.each do |r|
          row(color: @colors[1]) do
            column r[0]
            column r[1]
            column r[2]
          end
        end
      end
      draw_table
    end
  end

end; end
