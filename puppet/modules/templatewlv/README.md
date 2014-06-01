# templatewlv

## Template With Local Variables

A wrapper around puppet's template function. See
[the templating docs](http://docs.puppetlabs.com/guides/templating.html) for 
the basic functionality.

Additionally, you can pass a hash, as the last argument, which will be turned into
local variables and available to the template itself. This will allow you  to define
variables in a template and pass them down to a template you include in the current
template. An example:

    scope.function_templatewlv(['sub_template', { 'local_var' => 'value' }])
  
Note that if multiple templates are specified, their output is all
concatenated and returned as the output of the function.

# Who - License

duritong - Apache License, Version 2.0
