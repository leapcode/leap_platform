# A wrapper for templates, that allows you to additionally define
# local variables
class Puppet::Parser::TemplateWrapperWlv < Puppet::Parser::TemplateWrapper
  attr_reader :local_vars
  def initialize(scope, local_vars)
    super(scope)
    @local_vars = local_vars
  end

  # Should return true if a variable is defined, false if it is not
  def has_variable?(name)
    super(name) || local_vars.keys.include?(name.to_s)
  end

  def method_missing(name, *args)
    if local_vars.keys.include?(n=name.to_s)
      local_vars[n]
    else
      super(name, *args)
    end
  end

  def result(string = nil)
    # Expose all the variables in our scope as instance variables of the
    # current object, making it possible to access them without conflict
    # to the regular methods.
    benchmark(:debug, "Bound local template variables for #{@__file__}") do
      local_vars.each do |name, value|
        if name.kind_of?(String)
          realname = name.gsub(/[^\w]/, "_")
        else
          realname = name
        end
        instance_variable_set("@#{realname}", value)
      end
    end
    super(string)
  end
end
