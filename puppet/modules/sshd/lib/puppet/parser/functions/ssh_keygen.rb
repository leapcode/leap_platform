Puppet::Parser::Functions::newfunction(:ssh_keygen, :type => :rvalue, :doc =>
  "Returns an array containing the ssh private and public (in this order) key
  for a certain private key path.
  It will generate the keypair if both do not exist. It will also generate
  the directory hierarchy if required.
  It accepts only fully qualified paths, everything else will fail.") do |args|
    raise Puppet::ParseError, "Wrong number of arguments" unless args.to_a.length == 1
    private_key_path = args.to_a[0]
    raise Puppet::ParseError, "Only fully qualified paths are accepted (#{private_key_path})" unless private_key_path =~ /^\/.+/
    public_key_path = "#{private_key_path}.pub"
    raise Puppet::ParseError, "Either only the private or only the public key exists" if File.exists?(private_key_path) ^ File.exists?(public_key_path)
    [private_key_path,public_key_path].each do |path|
      raise Puppet::ParseError, "#{path} is a directory" if File.directory?(path)
    end

    dir = File.dirname(private_key_path)
    unless File.directory?(dir)
      require 'fileutils'
      FileUtils.mkdir_p(dir, :mode => 0700)
    end
    unless [private_key_path,public_key_path].all?{|path| File.exists?(path) }
      executor = (Facter.value(:puppetversion).to_i < 3) ? Puppet::Util : Puppet::Util::Execution
      output = executor.execute(
        ['/usr/bin/ssh-keygen','-t', 'rsa', '-b', '4096', 
         '-f', private_key_path, '-P', '', '-q'])
      raise Puppet::ParseError, "Something went wrong during key generation! Output: #{output}" unless output.empty?
    end
    [File.read(private_key_path),File.read(public_key_path)]
end

