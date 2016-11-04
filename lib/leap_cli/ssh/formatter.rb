#
# A custom SSHKit formatter that uses LeapLogger.
#

require 'sshkit'

module LeapCli
  module SSH

    class Formatter < SSHKit::Formatter::Abstract

      DEFAULT_OPTIONS = {
        :log_cmd => false,    # log what the command is that gets run.
        :log_output => true,  # log each output from the command as it is received.
        :log_finish => false  # log the exit status and time to completion.
      }

      def initialize(logger, host, options={})
        @logger = logger || LeapCli.new_logger
        @host = host
        @options = DEFAULT_OPTIONS.merge(options)
      end

      def write(obj)
        @logger.log(obj.to_s, :host => @host.hostname)
      end

      def log_command_start(command)
        if @options[:log_cmd]
          @logger.log(:running, "`" + command.to_s + "`", :host => @host.hostname)
        end
      end

      def log_command_data(command, stream_type, stream_data)
        if @options[:log_output]
          color = stream_type == :stderr ? :red : nil
          @logger.log(stream_data.to_s.chomp,
            :color => color, :host => @host.hostname, :wrap => options[:log_wrap])
        end
      end

      def log_command_exit(command)
        if @options[:log_finish]
          runtime = sprintf('%5.3fs', command.runtime)
          if command.failure?
            message = "in #{runtime} with status #{command.exit_status}."
            @logger.log(:failed, message, :host => @host.hostname)
          else
            message = "in #{runtime}."
            @logger.log(:completed, message, :host => @host.hostname)
          end
        end
      end
    end

  end
end

  #
  # A custom InteractionHandler that will output the results as they come in.
  #
  #class LoggingInteractionHandler
  #  def initialize(hostname, logger=nil)
  #    @hostname = hostname
  #    @logger = logger || LeapCli.new_logger
  #  end
  #  def on_data(command, stream_name, data, channel)
  #    @logger.log(data, host: @hostname, wrap: true)
  #  end
  #end
