class LeapTest

  #
  # works like pgrep command line
  # return an array of hashes like so [{:pid => "1234", :process => "ls"}]
  #
  def pgrep(match)
    output = `pgrep --full --list-name '#{match}'`
    output.each_line.map{|line|
      pid = line.split(' ')[0]
      process = line.gsub(/(#{pid} |\n)/, '')
      # filter out pgrep cmd itself
      # on wheezy hosts, the "process" var contains the whole cmd including all parameters
      # on jessie hosts, it only contains the first cmd (which is the default sheel invoked by 'sh')
      if process =~ /^sh/
        nil
      else
        {:pid => pid, :process => process}
      end
    }.compact
  end

  #
  # passes if the specified process is runnin.
  #
  # arguments:
  #
  #  match   => VALUE      -- scan process table for VALUE
  #  service => VALUE      -- call systemctl is-active VALUE
  #
  #  single  => true|false -- if true, there must be one result
  #
  def assert_running(match:nil, service:nil, single:false)
    if match
      processes = pgrep(match)
      assert processes.any?, "No running process for #{match}"
      if single
        assert processes.length == 1, "More than one process for #{match}"
      end
    elsif service
      `systemctl is-active #{service} 2>&1`
      if $?.exitstatus != 0
        output = `systemctl status #{service} 2>&1`
        fail "Service '#{service}' is not running:\n#{output}"
      end
    end
  end

  #
  # runs the specified command, failing on a non-zero exit status.
  #
  def assert_run(command)
    output = `#{command} 2>&1`
    if $?.exitstatus != 0
      fail "Error running `#{command}`:\n#{output}"
    end
  end

end