require 'fileutils'

module LeapCli
  module Util
    module Vagrant

      #
      # returns the path to a vagrant ssh private key file.
      #
      # if the vagrant.key file is owned by root or ourselves, then
      # we need to make sure that it owned by us and not world readable.
      #
      def self.vagrant_ssh_key_file
        file_path = Path.vagrant_ssh_priv_key_file
        Util.assert_files_exist! file_path
        uid = File.new(file_path).stat.uid
        if uid == 0 || uid == Process.euid
          FileUtils.install file_path, '/tmp/vagrant.key', :mode => 0600
          file_path = '/tmp/vagrant.key'
        end
        return file_path
      end

    end
  end
end