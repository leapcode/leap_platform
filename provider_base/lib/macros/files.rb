# encoding: utf-8

##
## FILES
##

module LeapCli
  module Macro

    #
    # inserts the contents of a file
    #
    def file(filename, options={})
      if filename.is_a? Symbol
        filename = [filename, @node.name]
      end
      filepath = Path.find_file(filename)
      if filepath
        if filepath =~ /\.erb$/
          ERB.new(File.read(filepath, :encoding => 'UTF-8'), nil, '%<>').result(binding)
        else
          File.read(filepath, :encoding => 'UTF-8')
        end
      else
        raise FileMissing.new(Path.named_path(filename), options)
        ""
      end
    end

    #
    # like #file, but allow missing files
    #
    def try_file(filename)
      return file(filename)
    rescue FileMissing
      return nil
    end

    #
    # returns what the file path will be, once the file is rsynced to the server.
    # an internal list of discovered file paths is saved, in order to rsync these files when needed.
    #
    # notes:
    #
    # * argument 'path' is relative to Path.provider/files or Path.provider_base/files
    # * the path returned by this method is absolute
    # * the path stored for use later by rsync is relative to Path.provider
    # * if the path does not exist locally, but exists in provider_base, then the default file from
    #   provider_base is copied locally. this is required for rsync to work correctly.
    #
    def file_path(path)
      if path.is_a? Symbol
        path = [path, @node.name]
      end
      actual_path = Path.find_file(path)
      if actual_path.nil?
        Util::log 2, :skipping, "file_path(\"#{path}\") because there is no such file."
        nil
      else
        if actual_path =~ /^#{Regexp.escape(Path.provider_base)}/
          # if file is under Path.provider_base, we must copy the default file to
          # to Path.provider in order for rsync to be able to sync the file.
          local_provider_path = actual_path.sub(/^#{Regexp.escape(Path.provider_base)}/, Path.provider)
          FileUtils.mkdir_p File.dirname(local_provider_path), :mode => 0700
          FileUtils.install actual_path, local_provider_path, :mode => 0600
          Util.log :created, Path.relative_path(local_provider_path)
          actual_path = local_provider_path
        end
        if File.directory?(actual_path) && actual_path !~ /\/$/
          actual_path += '/' # ensure directories end with /, important for building rsync command
        end
        relative_path = Path.relative_path(actual_path)
        @node.file_paths << relative_path
        @node.manager.provider.hiera_sync_destination + '/' + relative_path
      end
    end

  end
end