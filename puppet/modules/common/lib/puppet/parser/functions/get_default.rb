# get_default($value, $default) : $value
#
# return $value || $default.
module Puppet::Parser::Functions
    newfunction(:get_default, :type => :rvalue) do |args|
        value = nil
        args.each { |x|
            if ! x.nil? and x.length > 0
                value = x
                break
            end
        }
        return value
    end
end
