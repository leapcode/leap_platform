#
# Gather facter facts
#

module LeapCli; module Commands

  desc 'Gather information on nodes.'
  command :facts do |facts|
    facts.desc 'Query servers to update facts.json.'
    facts.long_desc "Queries every node included in FILTER and saves the important information to facts.json"
    facts.arg_name 'FILTER'
    facts.command :update do |update|
      update.action do |global_options,options,args|
        update_facts(global_options, options, args)
      end
    end
  end

  protected

  def facter_cmd
    'facter --json ' + Leap::Platform.facts.join(' ')
  end

  def remove_node_facts(name)
    if file_exists?(:facts)
      update_facts_file({name => nil})
    end
  end

  def update_node_facts(name, facts)
    update_facts_file({name => facts})
  end

  def rename_node_facts(old_name, new_name)
    if file_exists?(:facts)
      facts = JSON.parse(read_file(:facts) || {})
      facts[new_name] = facts[old_name]
      facts[old_name] = nil
      update_facts_file(facts, true)
    end
  end

  #
  # if overwrite = true, then ignore existing facts.json.
  #
  def update_facts_file(new_facts, overwrite=false)
    replace_file!(:facts) do |content|
      if overwrite || content.nil? || content.empty?
        old_facts = {}
      else
        old_facts = manager.facts
      end
      facts = old_facts.merge(new_facts)
      facts.each do |name, value|
        if value.is_a? String
          if value == ""
            value = nil
          else
            value = JSON.parse(value) rescue JSON::ParserError
          end
        end
        if value.is_a? Hash
          value.delete_if {|key,v| v.nil?}
        end
        facts[name] = value
      end
      facts.delete_if do |name, value|
        value.nil? || value.empty?
      end
      if facts.empty?
        "{}\n"
      else
        JSON.sorted_generate(facts) + "\n"
      end
    end
  end

  private

  def update_facts(global_options, options, args)
    require 'leap_cli/ssh'
    nodes = manager.filter(args, :local => false, :disabled => false)
    new_facts = {}
    SSH.remote_command(nodes) do |ssh, host|
      response = ssh.capture(facter_cmd, :log_output => false)
      if response
        log 'done', :host => host
        node = manager.node(host)
        if node
          new_facts[node.name] = response.strip
        else
          log :warning, 'Could not find node for hostname %s' % host
        end
      end
    end
    # only overwrite the entire facts file if and only if we are gathering facts
    # for all nodes in all environments.
    overwrite_existing = args.empty? && LeapCli.leapfile.environment.nil?
    update_facts_file(new_facts, overwrite_existing)
  end

end; end