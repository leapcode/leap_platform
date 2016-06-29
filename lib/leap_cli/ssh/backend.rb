#
# A custome SSHKit backend, derived from the default netssh backend.
# Our custom backend modifies the logging behavior and gracefully captures
# common exceptions.
#

require 'timeout'
require 'sshkit'
require 'leap_cli/ssh/formatter'
require 'leap_cli/ssh/scripts'

module SSHKit
  class Command
    #
    # override exit_status in order to be less verbose
    #
    def exit_status=(new_exit_status)
      @finished_at = Time.now
      @exit_status = new_exit_status
      if options[:raise_on_non_zero_exit] && exit_status > 0
        message = ""
        message += "exit status: " + exit_status.to_s + "\n"
        message += "stdout: " + (full_stdout.strip.empty? ? "Nothing written" : full_stdout.strip) + "\n"
        message += "stderr: " + (full_stderr.strip.empty? ? 'Nothing written' : full_stderr.strip) + "\n"
        raise Failed, message
      end
    end
  end
end

module LeapCli
  module SSH
    class Backend < SSHKit::Backend::Netssh

      # since the @pool is a class instance variable, we need to copy
      # the code from the superclass that initializes it. boo
      @pool = SSHKit::Backend::ConnectionPool.new

      # modify to pass itself to the block, instead of relying on instance_exec.
      def run
        Thread.current["sshkit_backend"] = self
        # was: instance_exec(@host, &@block)
        @block.call(self, @host)
      ensure
        Thread.current["sshkit_backend"] = nil
      end

      #
      # like default capture, but gracefully logs failures for us
      # last argument can be an options hash.
      #
      # available options:
      #
      #   :fail_msg    - [nil] if set, log this instead of the default
      #                  fail message.
      #
      #   :raise_error - [nil] if true, then reraise failed command exception.
      #
      #   :log_cmd     - [false] if true, log what the command is that gets run.
      #
      #   :log_output  - [true] if true, log each output from the command as
      #                  it is received.
      #
      #   :log_finish  - [false] if true, log the exit status and time
      #                  to completion
      #
      #   :log_wrap    - [nil] passed to log method as :wrap option.
      #
      def capture(*args)
        extract_options(args)
        initialize_logger(:log_output => false)
        rescue_ssh_errors(*args) do
          return super(*args)
        end
      end

      #
      # like default execute, but log the results as they come in.
      #
      # see capture() for available options
      #
      def stream(*args)
        extract_options(args)
        initialize_logger
        rescue_ssh_errors(*args) do
          execute(*args)
        end
      end

      def log(*args, &block)
        @logger ||= LeapCli.new_logger
        @logger.log(*args, &block)
      end

      # some prewritten servers-side scripts
      def scripts
        @scripts ||= LeapCli::SSH::Scripts.new(self, @host)
      end

      private

      #
      # creates a new logger instance for this specific ssh command.
      # by doing this, each ssh session has its own logger and its own
      # indentation.
      #
      # potentially modifies 'args' array argument.
      #
      def initialize_logger(default_options={})
        @logger ||= LeapCli.new_logger
        @output = LeapCli::SSH::Formatter.new(@logger, @host, default_options.merge(@options))
      end

      def extract_options(args)
        if args.last.is_a? Hash
          @options = args.pop
        else
          @options = {}
        end
      end

      #
      # capture common exceptions
      #
      def rescue_ssh_errors(*args, &block)
        yield
      rescue StandardError => exc
        if exc.is_a?(SSHKit::Command::Failed) || exc.is_a?(SSHKit::Runner::ExecuteError)
          if @options[:raise_error]
            raise LeapCli::SSH::ExecuteError, exc.to_s
          elsif @options[:fail_msg]
            @logger.log(@options[:fail_msg], host: @host.hostname, :color => :red)
          else
            @logger.log(:failed, args.join(' '), host: @host.hostname) do
              @logger.log(exc.to_s.strip, wrap: true)
            end
          end
        elsif exc.is_a?(Timeout::Error) || exc.is_a?(Net::SSH::ConnectionTimeout)
          @logger.log(:failed, args.join(' '), host: @host.hostname) do
            @logger.log("Connection timed out")
          end
        else
          raise
        end
        return nil
      end

      def output
        @output ||= LeapCli::SSH::Formatter.new(@logger, @host)
      end

    end
  end
end

