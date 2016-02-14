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
    # returns the location of a file that is stored on the local
    # host, under PROVIDER_DIR/files.
    #
    def local_file_path(path, options={})
      if path.is_a? Symbol
        path = [path, @node.name]
      elsif path.is_a? String
        # ensure it prefixed with files/
        unless path =~ /^files\//
          path = "files/" + path
        end
      end
      local_path = Path.find_file(path)
      if local_path.nil?
        if options[:missing]
          raise FileMissing.new(Path.named_path(path), options)
        elsif block_given?
          yield
          return local_file_path(path, options) # try again.
        else
          Util::log 2, :skipping, "local_file_path(\"#{path}\") because there is no such file."
          return nil
        end
      else
        local_path
      end
    end

    #
    # Returns the location of a file once it is deployed via rsync to the a
    # remote server. An internal list of discovered file paths is saved, in
    # order to rsync these files when needed.
    #
    # If there is a block given and the file does not actually exist, the
    # block will be yielded to give an opportunity for some code to create the
    # file.
    #
    # For example:
    #
    #   file_path(:dkim_priv_key) {generate_dkim_key}
    #
    # notes:
    #
    # * argument 'path' is relative to Path.provider/files or
    #   Path.provider_base/files
    # * the path returned by this method is absolute
    # * the path stored for use later by rsync is relative to Path.provider
    # * if the path does not exist locally, but exists in provider_base,
    #   then the default file from provider_base is copied locally. this
    #   is required for rsync to work correctly.
    #
    def remote_file_path(path, options={}, &block)
      local_path = local_file_path(path, options, &block)

      # if file is under Path.provider_base, we must copy the default file to
      # to Path.provider in order for rsync to be able to sync the file.
      if local_path =~ /^#{Regexp.escape(Path.provider_base)}/
        local_provider_path = local_path.sub(/^#{Regexp.escape(Path.provider_base)}/, Path.provider)
        FileUtils.mkdir_p File.dirname(local_provider_path), :mode => 0700
        FileUtils.install local_path, local_provider_path, :mode => 0600
        Util.log :created, Path.relative_path(local_provider_path)
        local_path = local_provider_path
      end

      # ensure directories end with /, important for building rsync command
      if File.directory?(local_path) && local_path !~ /\/$/
        local_path += '/'
      end

      relative_path = Path.relative_path(local_path)
      relative_path.sub!(/^files\//, '') # remove "files/" prefix
      @node.file_paths << relative_path
      File.join(Leap::Platform.files_dir, relative_path)
    end

    # deprecated
    def file_path(path, options={})
      remote_file_path(path, options)
    end

  end
end