Puppet::Parser::Functions::newfunction(
  :tfile,
  :type => :rvalue,
  :doc => "Returns the content of a file. If the file or the path does not
    yet exist, it will create the path and touch the file."
) do |args|
  raise Puppet::ParseError, 'tfile() needs one argument' if args.length != 1
  path = args.to_a.first
  unless File.exists?(path)
    dir = File.dirname(path)
    unless File.directory?(dir)
      require 'fileutils'
      FileUtils.mkdir_p(dir, :mode => 0700)
    end
    require 'fileutils'
    FileUtils.touch(path)
  end
  File.read(path)
end
