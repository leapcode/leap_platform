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
      if process =~ /pgrep --full --list-name/
        nil
      else
        {:pid => pid, :process => process}
      end
    }.compact
  end

  def assert_running(process)
    assert pgrep(process).any?, "No running process for #{process}"
  end

  #
  # runs the specified command, failing on a non-zero exit status.
  #
  def assert_run(command)
    output = `#{command}`
    if $?.exitstatus != 0
      fail "Error running `#{command}`:\n#{output}"
    end
  end

end