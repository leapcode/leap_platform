require File.join(File.dirname(__FILE__),'../templatewrapperwlv')
Puppet::Parser::Functions::newfunction(:templatewlv, :type => :rvalue, :arity => -2, :doc =>
  "A wrapper around puppet's template function. See
  [the templating docs](http://docs.puppetlabs.com/guides/templating.html) for 
  the basic functionality.

  Additionally, you can pass a hash, as the last argument, which will be turned into
  local variables and available to the template itself. This will allow you  to define
  variables in a template and pass them down to a template you include in the current
  template. An example:

    scope.function_templatewlv(['sub_template', { 'local_var' => 'value' }])
  
  Note that if multiple templates are specified, their output is all
  concatenated and returned as the output of the function.") do |vals|

    if vals.last.is_a?(Hash)
      local_vars = vals.last
      local_vals = vals[0..-2]
    else
      local_vars = {}
      local_vals = vals
    end

    result = nil
    local_vals.collect do |file|
      # Use a wrapper, so the template can't get access to the full
      # Scope object.
      debug "Retrieving template #{file}"

      wrapper = Puppet::Parser::TemplateWrapperWlv.new(self,local_vars)
      wrapper.file = file
      begin
        wrapper.result
      rescue => detail
        info = detail.backtrace.first.split(':')
        raise Puppet::ParseError,
          "Failed to parse template #{file}:\n  Filepath: #{info[0]}\n  Line: #{info[1]}\n  Detail: #{detail}\n"
      end
    end.join("")
end
