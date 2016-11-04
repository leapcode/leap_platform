#
# I am not sure this is a good idea, but it might be. Tricky, so disabled for now
#

=begin
module LeapCli
  class Cloud

    def self.check_required_gems
      begin
        require "fog"
      rescue LoadError
        bail! do
          log :error, "The 'vm' command requires the gem 'fog-core'. Please run `gem install fog-core` and try again."
        end
      end

      fog_gems = @cloud.required_gems
      if !options[:mock] && fog_gems.empty?
        bail! do
          log :warning, "no vm providers are configured in cloud.json."
          log "You must have credentials for one of: #{@cloud.possible_apis.join(', ')}."
        end
      end

      fog_gems.each do |name, gem_name|
        begin
          require gem_name.sub('-','/')
        rescue LoadError
          bail! do
            log :error, "The 'vm' command requires the gem '#{gem_name}' (because of what is configured in cloud.json)."
            log "Please run `sudo gem install #{gem_name}` and try again."
          end
        end
      end
    end

  end
end
=end