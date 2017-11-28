
#
# perhaps we want to verify that the key files are actually the key files we expect.
# we could use 'file' for this:
#
# > file ~/.gnupg/00440025.asc
# ~/.gnupg/00440025.asc: PGP public key block
#
# > file ~/.ssh/id_rsa.pub
# ~/.ssh/id_rsa.pub: OpenSSH RSA public key
#

module LeapCli
  module Commands

    desc 'Manage trusted sysadmins (DEPRECATED)'
    long_desc "Use `leap user add` instead"
    command :'add-user' do |c|
      c.switch 'self', :desc => 'Add yourself as a trusted sysadmin by choosing among the public keys available for the current user.', :negatable => false
      c.flag 'ssh-pub-key', :desc => 'SSH public key file for this new user'
      c.flag 'pgp-pub-key', :desc => 'OpenPGP public key file for this new user'
      c.action do |global_options,options,args|
        do_add_user(global_options, options, args)
      end
    end

    desc 'Manage trusted sysadmins'
    long_desc "Manage the trusted sysadmins that are configured in the 'users' directory."
    command :user do |user|

      user.desc 'Adds a new trusted sysadmin'
      user.arg_name 'USERNAME'
      user.command :add do |c|
        c.switch 'self', :desc => 'Add yourself as a trusted sysadmin by choosing among the public keys available for the current user.', :negatable => false
        c.flag 'ssh-pub-key', :desc => 'SSH public key file for this new user'
        c.flag 'pgp-pub-key', :desc => 'OpenPGP public key file for this new user'
        c.action do |global_options,options,args|
          do_add_user(global_options, options, args)
        end
      end

      user.desc 'Removes a trusted sysadmin'
      user.arg_name 'USERNAME'
      user.command :rm do |c|
        c.action do |global_options,options,args|
          do_rm_user(global_options, options, args)
        end
      end

      user.desc 'Lists the configured sysadmins'
      user.command :ls do |c|
        c.action do |global_options,options,args|
          do_list_users(global_options, options, args)
        end
      end

    end

    private

    def do_add_user(global, options, args)
      require 'leap_cli/ssh'

      username = args.first
      if !username.any?
        if options[:self]
          username ||= `whoami`.strip
        else
          help! "Either USERNAME argument or --self flag is required."
        end
      end
      if Leap::Platform.reserved_usernames.include? username
        bail! %(The username "#{username}" is reserved. Sorry, pick another.)
      end

      ssh_pub_key = nil
      pgp_pub_key = nil

      if options['ssh-pub-key']
        ssh_pub_key = read_file!(options['ssh-pub-key'])
      end
      if options['pgp-pub-key']
        pgp_pub_key = read_file!(options['pgp-pub-key'])
      end

      if options[:self]
        ssh_pub_key ||= pick_ssh_key.to_s
        pgp_pub_key ||= pick_pgp_key
      end

      assert!(ssh_pub_key, 'Sorry, could not find SSH public key.')

      if ssh_pub_key
        write_file!([:user_ssh, username], ssh_pub_key)
      end
      if pgp_pub_key
        write_file!([:user_pgp, username], pgp_pub_key)
      end

      update_authorized_keys
    end

    def do_rm_user(global, options, args)
      dir = [:user_dir, args.first]
      if Util.dir_exists?(dir)
        Util.remove_file!(dir)
        update_authorized_keys
      else
        bail! :error, 'There is no directory `%s`' % Path.named_path(dir)
      end
    end

    def do_list_users(global, options, args)
      require 'leap_cli/ssh'

      ssh_keys = {}
      Dir.glob("#{ENV['HOME']}/.ssh/*.pub").each do |keyfile|
        key = SSH::Key.load(keyfile)
        ssh_keys[key.fingerprint] = key if key
      end

      ssh_agent_keys = {}
      if !`which ssh-add`.empty?
        `ssh-add -L`.split("\n").each do |keystring|
          key = SSH::Key.load(keystring)
          ssh_agent_keys[key.fingerprint] = key if key
        end
      end

      Dir.glob(path([:user_ssh, '*'])).each do |keyfile|
        username = File.basename(File.dirname(keyfile))
        log username, :color => :cyan do
          log Path.relative_path(keyfile)
          key = SSH::Key.load(keyfile)
          if key.nil?
            log :warning, "could not read ssh key #{keyfile}" do
              log "currently, only these ssh key types are supported: " + SSH::Key::SUPPORTED_TYPES.join(", ")
            end
          else
            log 'SSH MD5 fingerprint: ' + key.fingerprint(:digest => :md5, :type => :ssh, :encoding => :hex)
            log 'SSH SHA256 fingerprint: ' + key.fingerprint(:digest => :sha256, :type => :ssh, :encoding => :base64)
            log 'DER MD5 fingerprint: ' + key.fingerprint(:digest => :md5, :type => :der, :encoding => :hex)
            if ssh_keys[key.fingerprint]
              log 'Matches local key: ' + ssh_keys[key.fingerprint].filename, color: :green
              if ssh_agent_keys[key.fingerprint]
                log 'Matches ssh-agent key: ' + ssh_agent_keys[key.fingerprint].summary(encoding: :base64), color: :green
              else
                log :error, 'No matching key in the ssh-agent'
              end
            end
          end
        end
      end
    end

    #
    # let the the user choose among the ssh public keys that we encounter, or
    # just pick the key if there is only one.
    #
    def pick_ssh_key
      ssh_keys = []
      Dir.glob("#{ENV['HOME']}/.ssh/*.pub").each do |keyfile|
        ssh_keys << SSH::Key.load(keyfile)
      end

      if `which ssh-add`.strip.any?
        `ssh-add -L 2> /dev/null`.split("\n").compact.each do |line|
          key = SSH::Key.load(line)
          if key
            key.comment = 'ssh-agent'
            ssh_keys << key unless ssh_keys.include?(key)
          end
        end
      end
      ssh_keys.compact!

      assert! ssh_keys.any?, 'Sorry, could not find any SSH public key for you. Have you run ssh-keygen?'

      if ssh_keys.length > 1
        key_index = numbered_choice_menu('Choose your SSH public key', ssh_keys.collect(&:summary)) do |line, i|
          say("#{i+1}. #{line}")
        end
      else
        key_index = 0
        log "Picking the only compatible ssh key: "+ ssh_keys[key_index].filename do
          log ssh_keys[key_index].summary
        end
      end

      return ssh_keys[key_index]
    end

    #
    # let the the user choose among the gpg public keys that we encounter, or just pick the key if there is only one.
    #
    def pick_pgp_key
      begin
        require 'gpgme'
      rescue LoadError
        log "Skipping OpenPGP setup because gpgme is not installed."
        return
      end

      secret_keys = GPGME::Key.find(:secret)
      if secret_keys.empty?
        log "Skipping OpenPGP setup because I could not find any OpenPGP keys for you"
        return nil
      end

      secret_keys.select!{|key| !key.expired}

      if secret_keys.length > 1
        key_index = numbered_choice_menu('Choose your OpenPGP public key', secret_keys) do |key, i|
          key_info = key.to_s.split("\n")[0..1].map{|line| line.sub(/^\s*(sec|uid)\s*/,'')}.join(' -- ')
          say("#{i+1}. #{key_info}")
        end
      else
        key_index = 0
      end

      key_id = secret_keys[key_index].sha

      # can't use this, it includes signatures:
      #puts GPGME::Key.export(key_id, :armor => true, :export_options => :export_minimal)

      # export with signatures removed:
      return `gpg --armor --export-options export-minimal --export #{key_id}`.strip
    end

  end
end
