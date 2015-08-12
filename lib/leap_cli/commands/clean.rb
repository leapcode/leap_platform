module LeapCli
  module Commands

    desc 'Removes all files generated with the "compile" command.'
    command :clean do |c|
      c.action do |global_options,options,args|
        Dir.glob(path([:hiera, '*'])).each do |file|
          remove_file! file
        end
        remove_file! path(:authorized_keys)
        remove_file! path(:known_hosts)
      end
    end

  end
end