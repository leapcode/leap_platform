module Puppet::Parser::Functions
  newfunction(:rotated_db_name, :type => :rvalue, :doc => <<-EOS
This function takes a database name string and returns a database name with the current rotation stamp appended.
The first argument is the base name of the database. Subsequent arguments may contain these options:
  * 'next'    -- return the db name for the next rotation, not the current one.
  * 'monthly' -- rotate monthly (default)
  * 'weekly'  -- rotate weekly
*Examples:*
    rotated_db_name('tokens') => 'tokens_551'
    EOS
  ) do |arguments|
    if arguments.include?('weekly')
      rotation_period = 604800 # 1 week
    else
      rotation_period = 2592000 # 1 month
    end
    suffix = Time.now.utc.to_i / rotation_period
    if arguments.include?('next')
      suffix += 1
    end
    "#{arguments.first}_#{suffix}"
  end
end

