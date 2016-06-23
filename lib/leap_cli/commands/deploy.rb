require 'etc'

module LeapCli
  module Commands

    desc 'Apply recipes to a node or set of nodes.'
    long_desc 'The FILTER can be the name of a node, service, or tag.'
    arg_name 'FILTER'
    command [:deploy, :d] do |c|

      c.switch :fast, :desc => 'Makes the deploy command faster by skipping some slow steps. A "fast" deploy can be used safely if you recently completed a normal deploy.',
                      :negatable => false

      c.switch :sync, :desc => "Sync files, but don't actually apply recipes.", :negatable => false

      c.switch :force, :desc => 'Deploy even if there is a lockfile.', :negatable => false

      c.switch :downgrade, :desc => 'Allows deploy to run with an older platform version.', :negatable => false

      c.switch :dev, :desc => "Development mode: don't run 'git submodule update' before deploy.", :negatable => false

      c.flag :tags, :desc => 'Specify tags to pass through to puppet (overriding the default).',
                    :arg_name => 'TAG[,TAG]'

      c.flag :port, :desc => 'Override the default SSH port.',
                    :arg_name => 'PORT'

      c.flag :ip,   :desc => 'Override the default SSH IP address.',
                    :arg_name => 'IPADDRESS'

      c.action do |global,options,args|
        run_deploy(global, options, args)
      end
    end

    desc 'Display recent deployment history for a set of nodes.'
    long_desc 'The FILTER can be the name of a node, service, or tag.'
    arg_name 'FILTER'
    command [:history, :h] do |c|
      c.flag   :port, :desc => 'Override the default SSH port.',
                      :arg_name => 'PORT'
      c.flag   :ip,   :desc => 'Override the default SSH IP address.',
                      :arg_name => 'IPADDRESS'
      c.switch :last, :desc => 'Show last deploy only',
                      :negatable => false
      c.action do |global,options,args|
        run_history(global, options, args)
      end
    end

    private

    def run_deploy(global, options, args)
      require 'leap_cli/ssh'

      if options[:dev] != true
        init_submodules
      end

      nodes = manager.filter!(args, :disabled => false)
      if nodes.size > 1
        say "Deploying to these nodes: #{nodes.keys.join(', ')}"
        if !global[:yes] && !agree("Continue? ")
          quit! "OK. Bye."
        end
      end

      environments = nodes.field('environment').uniq
      if environments.empty?
        environments = [nil]
      end
      environments.each do |env|
        check_platform_pinning(env, global)
      end

      # compile hiera files for all the nodes in every environment that is
      # being deployed and only those environments.
      compile_hiera_files(manager.filter(environments), false)

      log :checking, 'nodes' do
        SSH.remote_command(nodes, options) do |ssh, host|
          begin
            ssh.scripts.check_for_no_deploy
            ssh.scripts.assert_initialized
          rescue SSH::ExecuteError
            # skip nodes with errors, but run others
            nodes.delete(host.hostname)
          end
        end
      end

      log :synching, "configuration files" do
        sync_hiera_config(nodes, options)
        sync_support_files(nodes, options)
      end
      log :synching, "puppet manifests" do
        sync_puppet_files(nodes, options)
      end

      unless options[:sync]
        log :applying, "puppet" do
          SSH.remote_command(nodes, options) do |ssh, host|
            ssh.scripts.puppet_apply(
              :verbosity => [LeapCli.log_level,5].min,
              :tags => tags(options),
              :force => options[:force],
              :info => deploy_info,
              :downgrade => options[:downgrade]
            )
          end
        end
      end
    end

    def run_history(global, options, args)
      require 'leap_cli/ssh'

      if options[:last] == true
        lines = 1
      else
        lines = 10
      end
      nodes = manager.filter!(args)
      SSH.remote_command(nodes, options) do |ssh, host|
        ssh.scripts.history(lines)
      end
    end

    def forcible_prompt(forced, msg, prompt)
      say(msg)
      if forced
        log :warning, "continuing anyway because of --force"
      else
        say "hint: use --force to skip this prompt."
        quit!("OK. Bye.") unless agree(prompt)
      end
    end

    #
    # The currently activated provider.json could have loaded some pinning
    # information for the platform. If this is the case, refuse to deploy
    # if there is a mismatch.
    #
    # For example:
    #
    # "platform": {
    #   "branch": "develop"
    #   "version": "1.0..99"
    #   "commit": "e1d6280e0a8c565b7fb1a4ed3969ea6fea31a5e2..HEAD"
    # }
    #
    def check_platform_pinning(environment, global_options)
      provider = manager.env(environment).provider
      return unless provider['platform']

      if environment.nil? || environment == 'default'
        provider_json = 'provider.json'
      else
        provider_json = 'provider.' + environment + '.json'
      end

      # can we have json schema verification already?
      unless provider.platform.is_a? Hash
        bail!('`platform` attribute in #{provider_json} must be a hash (was %s).' % provider.platform.inspect)
      end

      # check version
      if provider.platform['version']
        if !Leap::Platform.version_in_range?(provider.platform.version)
          forcible_prompt(
            global_options[:force],
            "The platform is pinned to a version range of '#{provider.platform.version}' "+
              "by the `platform.version` property in #{provider_json}, but the platform "+
              "(#{Path.platform}) has version #{Leap::Platform.version}.",
            "Do you really want to deploy from the wrong version? "
          )
        end
      end

      # check branch
      if provider.platform['branch']
        if !is_git_directory?(Path.platform)
          forcible_prompt(
            global_options[:force],
            "The platform is pinned to a particular branch by the `platform.branch` property "+
              "in #{provider_json}, but the platform directory (#{Path.platform}) is not a git repository.",
            "Do you really want to deploy anyway? "
          )
        end
        unless provider.platform.branch == current_git_branch(Path.platform)
          forcible_prompt(
            global_options[:force],
            "The platform is pinned to branch '#{provider.platform.branch}' by the `platform.branch` property "+
              "in #{provider_json}, but the current branch is '#{current_git_branch(Path.platform)}' " +
              "(for directory '#{Path.platform}')",
            "Do you really want to deploy from the wrong branch? "
          )
        end
      end

      # check commit
      if provider.platform['commit']
        if !is_git_directory?(Path.platform)
          forcible_prompt(
            global_options[:force],
            "The platform is pinned to a particular commit range by the `platform.commit` property "+
              "in #{provider_json}, but the platform directory (#{Path.platform}) is not a git repository.",
            "Do you really want to deploy anyway? "
          )
        end
        current_commit = current_git_commit(Path.platform)
        Dir.chdir(Path.platform) do
          commit_range = assert_run!("git log --pretty='format:%H' '#{provider.platform.commit}'",
            "The platform is pinned to a particular commit range by the `platform.commit` property "+
            "in #{provider_json}, but git was not able to find commits in the range specified "+
            "(#{provider.platform.commit}).")
          commit_range = commit_range.split("\n")
          if !commit_range.include?(current_commit) &&
              provider.platform.commit.split('..').first != current_commit
            forcible_prompt(
              global_options[:force],
              "The platform is pinned via the `platform.commit` property in #{provider_json} " +
                "to a commit in the range #{provider.platform.commit}, but the current HEAD " +
                "(#{current_commit}) is not in that range.",
              "Do you really want to deploy from the wrong commit? "
            )
          end
        end
      end
    end

    def sync_hiera_config(nodes, options)
      SSH.remote_sync(nodes, options) do |sync, host|
        node = manager.node(host.hostname)
        hiera_file = Path.relative_path([:hiera, node.name])
        sync.log hiera_file + ' -> ' + node.name + ':' + Leap::Platform.hiera_path
        sync.source = hiera_file
        sync.dest = Leap::Platform.hiera_path
        sync.flags = "-rltp --chmod=u+rX,go-rwx"
        sync.exec
      end
    end

    #
    # sync various support files.
    #
    def sync_support_files(nodes, options)
      dest_dir     = Leap::Platform.files_dir
      custom_files = build_custom_file_list
      SSH.remote_sync(nodes, options) do |sync, host|
        node = manager.node(host.hostname)
        files_to_sync = node.file_paths.collect {|path| Path.relative_path(path, Path.provider) }
        files_to_sync += custom_files
        if files_to_sync.any?
          sync.log(files_to_sync.join(', ') + ' -> ' + node.name + ':' + dest_dir)
          sync.chdir = Path.named_path(:files_dir)
          sync.source = "."
          sync.dest = dest_dir
          sync.excludes = "*"
          sync.includes = calculate_includes_from_files(files_to_sync, '/files')
          sync.flags = "-rltp --chmod=u+rX,go-rwx --relative --delete --delete-excluded --copy-links"
          sync.exec
        end
      end
    end

    def sync_puppet_files(nodes, options)
      SSH.remote_sync(nodes, options) do |sync, host|
        sync.log(Path.platform + '/[bin,tests,puppet] -> ' + host.hostname + ':' + Leap::Platform.leap_dir)
        sync.dest = Leap::Platform.leap_dir
        sync.source = '.'
        sync.chdir = Path.platform
        sync.excludes = '*'
        sync.includes = ['/bin', '/bin/**', '/puppet', '/puppet/**', '/tests', '/tests/**']
        sync.flags = "-rlt --relative --delete --copy-links"
        sync.exec
      end
    end

    #
    # ensure submodules are up to date, if the platform is a git
    # repository.
    #
    def init_submodules
      return unless is_git_directory?(Path.platform)
      Dir.chdir Path.platform do
        assert_run! "git submodule sync"
        statuses = assert_run! "git submodule status"
        statuses.strip.split("\n").each do |status_line|
          if status_line =~ /^[\+-]/
            submodule = status_line.split(' ')[1]
            log "Updating submodule #{submodule}"
            assert_run! "git submodule update --init #{submodule}"
          end
        end
      end
    end

    #
    # converts an array of file paths into an array
    # suitable for --include of rsync
    #
    # if set, `prefix` is stripped off.
    #
    def calculate_includes_from_files(files, prefix=nil)
      return nil unless files and files.any?

      # prepend '/' (kind of like ^ for rsync)
      includes = files.collect {|file| file =~ /^\// ? file : '/' + file }

      # include all sub files of specified directories
      includes.size.times do |i|
        if includes[i] =~ /\/$/
          includes << includes[i] + '**'
        end
      end

      # include all parent directories (required because of --exclude '*')
      includes.size.times do |i|
        path = File.dirname(includes[i])
        while(path != '/')
          includes << path unless includes.include?(path)
          path = File.dirname(path)
        end
      end

      if prefix
        includes.map! {|path| path.sub(/^#{Regexp.escape(prefix)}\//, '/')}
      end

      return includes
    end

    def tags(options)
      if options[:tags]
        tags = options[:tags].split(',')
      else
        tags = Leap::Platform.default_puppet_tags.dup
      end
      tags << 'leap_slow' unless options[:fast]
      tags.join(',')
    end

    #
    # a provider might have various customization files that should be sync'ed to the server.
    # this method builds that list of files to sync.
    #
    def build_custom_file_list
      custom_files = []
      Leap::Platform.paths.keys.grep(/^custom_/).each do |path|
        if file_exists?(path)
          relative_path = Path.relative_path(path, Path.provider)
          if dir_exists?(path)
            custom_files << relative_path + '/' # rsync needs trailing slash
          else
            custom_files << relative_path
          end
        end
      end
      return custom_files
    end

    def deploy_info
      info = []
      info << "user: %s" % Etc.getpwuid(Process.euid).name
      if is_git_directory?(Path.platform) && current_git_branch(Path.platform) != 'master'
        info << "platform: %s (%s %s)" % [
          Leap::Platform.version,
          current_git_branch(Path.platform),
          current_git_commit(Path.platform)[0..4]
        ]
      else
        info << "platform: %s" % Leap::Platform.version
      end
      if is_git_directory?(LEAP_CLI_BASE_DIR)
        info << "leap_cli: %s (%s %s)" % [
          LeapCli::VERSION,
          current_git_branch(LEAP_CLI_BASE_DIR),
          current_git_commit(LEAP_CLI_BASE_DIR)[0..4]
        ]
      else
        info << "leap_cli: %s" % LeapCli::VERSION
      end
      info.join(', ')
    end
  end
end
