#
# A module to hide, modify, and colorize log entries.
#

module LeapCli
  module LogFilter
    #
    # options for formatters:
    #
    # :match       => regexp for matching a log line
    # :color       => what color the line should be
    # :style       => what style the line should be
    # :priority    => what order the formatters are applied in. higher numbers first.
    # :match_level => only apply filter at the specified log level
    # :level       => make this line visible at this log level or higher
    # :replace     => replace the matched text
    # :prepend     => insert text at start of message
    # :append      => append text to end of message
    # :exit        => force the exit code to be this (does not interrupt program, just
    #                 ensures a specific exit code when the program eventually exits)
    #
    FORMATTERS = [
      # TRACE
      { :match => /command finished/,          :color => :white,   :style => :dim, :match_level => 3, :priority => -10 },
      { :match => /executing locally/,         :color => :yellow,  :match_level => 3, :priority => -20 },

      # DEBUG
      #{ :match => /executing .*/,             :color => :green,   :match_level => 2, :priority => -10, :timestamp => true },
      #{ :match => /.*/,                       :color => :yellow,  :match_level => 2, :priority => -30 },
      { :match => /^transaction:/,             :level => 3 },

      # INFO
      { :match => /.*out\] (fatal:|ERROR:).*/, :color => :red,     :match_level => 1, :priority => -10 },
      { :match => /Permission denied/,         :color => :red,     :match_level => 1, :priority => -20 },
      { :match => /sh: .+: command not found/, :color => :magenta, :match_level => 1, :priority => -30 },

      # IMPORTANT
      { :match => /^(E|e)rr ::/,               :color => :red,     :match_level => 0, :priority => -10, :exit => 1},
      { :match => /^ERROR:/,                   :color => :red,                        :priority => -10, :exit => 1},
      #{ :match => /.*/,                        :color => :blue,    :match_level => 0, :priority => -20 },

      # CLEANUP
      #{ :match => /\s+$/,                      :replace => '', :priority => 0},

      # DEBIAN PACKAGES
      { :match => /^(Hit|Ign) /,                :color => :green,   :priority => -20},
      { :match => /^Err /,                      :color => :red,     :priority => -20},
      { :match => /^W(ARNING)?: /,              :color => :yellow,  :priority => -20},
      { :match => /^E: /,                       :color => :red,     :priority => -20},
      { :match => /already the newest version/, :color => :green,   :priority => -20},
      { :match => /WARNING: The following packages cannot be authenticated!/, :color => :red, :level => 0, :priority => -10},

      # PUPPET
      { :match => /^(W|w)arning: Not collecting exported resources without storeconfigs/, :level => 2, :color => :yellow, :priority => -10},
      { :match => /^(W|w)arning: Found multiple default providers for vcsrepo:/,          :level => 2, :color => :yellow, :priority => -10},
      { :match => /^(W|w)arning: .*is deprecated.*$/, :level => 2, :color => :yellow, :priority => -10},
      { :match => /^(W|w)arning: Scope.*$/,           :level => 2, :color => :yellow, :priority => -10},
      #{ :match => /^(N|n)otice:/,                     :level => 1, :color => :cyan,   :priority => -20},
      #{ :match => /^(N|n)otice:.*executed successfully$/, :level => 2, :color => :cyan, :priority => -15},
      { :match => /^(W|w)arning:/,                    :level => 0, :color => :yellow, :priority => -20},
      { :match => /^Duplicate declaration:/,          :level => 0, :color => :red,    :priority => -20},
      #{ :match => /Finished catalog run/,             :level => 0, :color => :green,  :priority => -10},
      { :match => /^APPLY COMPLETE \(changes made\)/, :level => 0, :color => :green, :style => :bold, :priority => -10},
      { :match => /^APPLY COMPLETE \(no changes\)/,   :level => 0, :color => :green, :style => :bold, :priority => -10},

      # PUPPET FATAL ERRORS
      { :match => /^(E|e)rr(or|):/,                :level => 0, :color => :red, :priority => -1, :exit => 1},
      { :match => /^Wrapped exception:/,           :level => 0, :color => :red, :priority => -1, :exit => 1},
      { :match => /^Failed to parse template/,     :level => 0, :color => :red, :priority => -1, :exit => 1},
      { :match => /^Execution of.*returned/,       :level => 0, :color => :red, :priority => -1, :exit => 1},
      { :match => /^Parameter matches failed:/,    :level => 0, :color => :red, :priority => -1, :exit => 1},
      { :match => /^Syntax error/,                 :level => 0, :color => :red, :priority => -1, :exit => 1},
      { :match => /^Cannot reassign variable/,     :level => 0, :color => :red, :priority => -1, :exit => 1},
      { :match => /^Could not find template/,      :level => 0, :color => :red, :priority => -1, :exit => 1},
      { :match => /^APPLY COMPLETE.*fail/,         :level => 0, :color => :red, :style => :bold, :priority => -1, :exit => 1},

      # TESTS
      { :match => /^PASS: /,                :color => :green,   :priority => -20},
      { :match => /^(FAIL|ERROR): /,        :color => :red,     :priority => -20},
      { :match => /^(SKIP|WARN): /,         :color => :yellow,  :priority => -20},
      { :match => /\d+ tests: \d+ passes, \d+ skips, 0 warnings, 0 failures, 0 errors/,
        :color => :green, :style => :bold, :priority => -20 },
      { :match => /\d+ tests: \d+ passes, \d+ skips, [1-9][0-9]* warnings, 0 failures, 0 errors/,
        :color => :yellow, :style => :bold,  :priority => -20 },
      { :match => /\d+ tests: \d+ passes, \d+ skips, \d+ warnings, \d+ failures, [1-9][0-9]* errors/,
        :color => :red, :style => :bold, :priority => -20 },
      { :match => /\d+ tests: \d+ passes, \d+ skips, \d+ warnings, [1-9][0-9]* failures, \d+ errors/,
        :color => :red, :style => :bold, :priority => -20 },

      # LOG SUPPRESSION
      { :match => /^(W|w)arning: You cannot collect without storeconfigs being set/, :level => 2, :priority => 10},
      { :match => /^(W|w)arning: You cannot collect exported resources without storeconfigs being set/, :level => 2, :priority => 10}
    ]

    SORTED_FORMATTERS = FORMATTERS.sort_by { |i| -(i[:priority] || i[:prio] || 0) }

    #
    # same as normal formatters, but only applies to the title, not the message.
    #
    TITLE_FORMATTERS = [
      # red
      { :match => /fatal_error/, :replace => 'fatal error:', :color => :red, :style => :bold },
      { :match => /error/, :color => :red, :style => :bold },
      { :match => /removed/, :color => :red, :style => :bold },
      { :match => /removing/, :color => :red, :style => :bold },
      { :match => /destroyed/, :color => :red, :style => :bold },
      { :match => /destroying/, :color => :red, :style => :bold },
      { :match => /terminated/, :color => :red, :style => :bold },
      { :match => /failed/, :replace => 'FAILED', :color => :red, :style => :bold },
      { :match => /bailing/, :replace => 'bailing', :color => :red, :style => :bold },
      { :match => /invalid/, :color => :red, :style => :bold },

      # yellow
      { :match => /warning/, :replace => 'warning:', :color => :yellow, :style => :bold },
      { :match => /missing/, :color => :yellow, :style => :bold },
      { :match => /skipping/, :color => :yellow, :style => :bold },

      # green
      { :match => /created/, :color => :green, :style => :bold },
      { :match => /completed/, :color => :green, :style => :bold },
      { :match => /ran/, :color => :green, :style => :bold },
      { :match => /^registered/, :color => :green, :style => :bold },

      # cyan
      { :match => /note/, :replace => 'NOTE:', :color => :cyan, :style => :bold },

      # magenta
      { :match => /nochange/, :replace => 'no change', :color => :magenta },
      { :match => /^loading/, :color => :magenta },
    ]

    def self.apply_message_filters(message)
      return self.apply_filters(SORTED_FORMATTERS, message)
    end

    def self.apply_title_filters(title)
      return self.apply_filters(TITLE_FORMATTERS, title)
    end

    private

    def self.apply_filters(formatters, message)
      level = LeapCli.logger.log_level
      result = {}
      formatters.each do |formatter|
        if (formatter[:match_level] == level || formatter[:match_level].nil?)
          if message =~ formatter[:match]
            # puts "applying formatter #{formatter.inspect}"
            result[:level] = formatter[:level] if formatter[:level]
            result[:color] = formatter[:color] if formatter[:color]
            result[:style] = formatter[:style] || formatter[:attribute] # (support original cap colors)

            message.gsub!(formatter[:match], formatter[:replace]) if formatter[:replace]
            message.replace(formatter[:prepend] + message) unless formatter[:prepend].nil?
            message.replace(message + formatter[:append])  unless formatter[:append].nil?
            message.replace(Time.now.strftime('%Y-%m-%d %T') + ' ' + message) if formatter[:timestamp]

            if formatter[:exit]
              LeapCli::Util.exit_status(formatter[:exit])
            end

            # stop formatting, unless formatter was just for string replacement
            break unless formatter[:replace]
          end
        end
      end

      if result[:color] == :hide
        return [nil, {}]
      else
        return [message, result]
      end
    end

  end
end
