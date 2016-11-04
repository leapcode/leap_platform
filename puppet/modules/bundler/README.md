puppet-bundler - Bundler gem manager for Ruby
==========================================

This puppet module will install bundler and set config 
variables.

This module supports Ubuntu 10.04 and Debian

Installation
------------

1. Copy this directory to your puppet master module path $(git clone
https://github.com/evanstachowiak/puppet-bundler bundler)

2. Apply the `bundler` class to any nodes you want bundler installed on:

  class { 'bundler::install': }

   By default this will install bundler with RVM, if you wish to use another
   method, you can pass any puppet package provider to the class as
   'install_method', or just use 'package' if you wish the puppet parser to
   automatically chose the best method for your platform.

  Examples: class { 'bundler::install': install_method => 'fink' }
            class { 'bundler::install': install_method => 'gem' }
            class { 'bundler::install': install_method => 'package' }

3. Set whatever config variables are necessary: 
   bundler::config { 'linecache19':
    user        => ubuntu,
    config_flag => "--with-ruby-include=/usr/local/rvm/src/ruby-1.9.2-p290",
    app_dir     => your_app_dir,
  }


Contributing
------------

- fork on github (https://github.com/evanstachowiak/puppet-bundler)
- send a pull request

Author
------
Evan Stachowiak (https://github.com/evanstachowiak)

LICENSE
-------

    Author:: Evan Stachowiak
    Copyright:: Copyright (c) 2012 Evan Stachowiak
    License:: Apache License, Version 2.0

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
