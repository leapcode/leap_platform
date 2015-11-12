module LeapCli
  module Commands

    desc "Manipulate and query environment information."
    long_desc "The 'environment' node property can be used to isolate sets of nodes into entirely separate environments. "+
      "A node in one environment will never interact with a node from another environment. "+
      "Environment pinning works by modifying your ~/.leaprc file and is dependent on the "+
      "absolute file path of your provider directory (pins don't apply if you move the directory)"
    command [:env, :e] do |c|
      c.desc "List the available environments. The pinned environment, if any, will be marked with '*'. Will also set the pin if run with an environment argument."
      c.arg_name 'ENVIRONMENT', :optional => true
      c.command :ls do |ls|
        ls.action do |global_options, options, args|
          environment = get_env_from_args(args)
          if environment
            pin(environment)
            LeapCli.leapfile.load
          end
          print_envs
        end
      end

      c.desc 'Pin the environment to ENVIRONMENT. All subsequent commands will only apply to nodes in this environment.'
      c.arg_name 'ENVIRONMENT'
      c.command :pin do |pin|
        pin.action do |global_options,options,args|
          environment = get_env_from_args(args)
          if environment
            pin(environment)
          else
            bail! "There is no environment `#{environment}`"
          end
        end
      end

      c.desc "Unpin the environment. All subsequent commands will apply to all nodes."
      c.command :unpin do |unpin|
        unpin.action do |global_options, options, args|
          LeapCli.leapfile.unset('environment')
          log 0, :saved, "~/.leaprc, removing environment property."
        end
      end

      c.default_command :ls
    end

    protected

    def get_env_from_args(args)
      environment = args.first
      if environment == 'default' || (environment && manager.environment_names.include?(environment))
        return environment
      else
        return nil
      end
    end

    def pin(environment)
      LeapCli.leapfile.set('environment', environment)
      log 0, :saved, "~/.leaprc with environment set to #{environment}."
    end

    def print_envs
      envs = ["default"] + manager.environment_names.compact.sort
      envs.each do |env|
        if env
          if LeapCli.leapfile.environment == env
            puts "* #{env}"
          else
            puts "  #{env}"
          end
        end
      end
    end
  end
end