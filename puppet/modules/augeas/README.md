# Augeas Puppet module

[![Puppet Forge](http://img.shields.io/puppetforge/v/camptocamp/augeas.svg)](https://forge.puppetlabs.com/camptocamp/augeas)
[![Build Status](https://travis-ci.org/camptocamp/puppet-augeas.png?branch=master)](https://travis-ci.org/camptocamp/puppet-augeas)

**Install and configure Augeas.**

This module is provided by [Camptocamp](http://www.camptocamp.com/)

## Usage

Simple usage:

    include augeas

### Classes

The module provides an `augeas` class which installs and configures Augeas.


* lets you force the augeas version by defining `$augeas_version`, otherwise puppet will
   only ensure the packages are present;
* lets you force the ruby library version by defining `$augeas_ruby_version`, otherwise puppet will
   only ensure the libaugeas-ruby version will be installed according to internal critera;
* provides an `augeas()` master-side function to manipulate strings using Augeas;

Note: the `augeas` class realizes all `augeas` resources in order to ensure they are managed after the required Augeas packages.


### Definitions

#### `augeas::lens`

The `augeas::lens` definition allows you to deploy an Augeas lens and any associated test files, running unit tests and not installing if they fail:

Parameters:

- *ensure*: present/absent
- *lens_source*: the source for the lens
- *test_source*: optionally, the source for the test file.
- *stock_since*: optionally, indicate in which version of Augeas
  the lens became stock, so it will not be deployed above that version.

Example usage:

     augeas::lens { 'networkmanager':
      lens_source => 'puppet:///modules/networkmanager/lenses/networkmanager.aug',
      test_source => 'puppet:///modules/networkmanager/lenses/test_networkmanager.aug',
      stock_since => '1.0.0',
     }

### Functions

#### `augeas()`

Modifies a string using Augeas.

*Example:*

    augeas("proc        /proc   proc    nodev,noexec,nosuid     0       0\n", 'Fstab.lns', ['rm ./1/opt[3]'])

Would result in:

    "proc        /proc   proc    nodev,noexec     0       0\n"


- *Type*: rvalue

## Contributing

Please report bugs and feature request using [GitHub issue
tracker](https://github.com/camptocamp/puppet-augeas/issues).

For pull requests, it is very much appreciated to check your Puppet manifest
with [puppet-lint](https://github.com/camptocamp/puppet-augeas/issues) to follow the recommended Puppet style guidelines from the
[Puppet Labs style guide](http://docs.puppetlabs.com/guides/style_guide.html).
