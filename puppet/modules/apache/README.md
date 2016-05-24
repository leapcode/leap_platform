Puppet module for managing an Apache web server
===============================================

This module tries to manage apache on different distros in a similar manner. a
few additional directories have to be created as well some configuration files
have to be deployed to fit this schema.

! Upgrade Notices !

 * The $ssl_cipher_suite has been evaluated from the `cert` module in the
   past, but is now a hardcoded default for the sake of reducing dependency
   to other modules. If you were using the `cert` module before, you should
   pass this parameter when declaring the apache class !

 * this module now only works with puppet 2.7 or newer

 * this module now uses parameterized classes, if you were using global
   variables before, you need to change the class declarations in your manifests

 * this module now requires the stdlib module

 * this module no longer requires the common module

 * if using the munin module, you need a version of the munin module that is
   at or newer than commit 77e0a70999a8c4c20ee8d9eb521b927c525ac653 (Feb 28, 2013)

 * if using munin, you will need to have the perl module installed

 * you must change your modules/site-apache to modules/site_apache

 * the $apache_no_default_site variable is no longer supported, you should
   switch to passing the parameter "no_default_site => true" to the apache class

 * the $use_munin variable is no longer supported, you should switch to
   passing the parameter 'manage_munin' to the apache class

 * the $use_shorewall variable is no longer supported, you should switch to
   passing the parameter 'manage_shorewall' to the apache class

 * if you were using apache::vhost::file, or apache::vhost::template, there is a
   wrapper called apache::vhost now that takes a $vhost_mode (either the default
   'template', or 'file), although you can continue to use the longer defines

 * Previously, apache::config::file resources would require the source to be a
   full source specification, this is no longer needed, so please change any:

      source => "puppet:///modules/site-apache/blah"

   to be:

      source => "modules/site-apache/blah"


Requirements
------------

 * puppet 2.7 or newer
 * stdlib module
 * templatewlv module
 * facter >= 2.2
   because we check for $::operatingsystemmajrelease on multiple places.
   In Debian wheezy, facter needs to get upgraded from wheezy-backports.
   The facter version of Debian jessie is new enough.

Usage
=====

Installing Apache
-----------------

To install Apache, simply include the 'apache' class in your manifests:

    include apache

This will give you a basic managed setup. You can pass a couple parameters to the
class to have the module do some things for you:

  * manage_shorewall: If you have the shorewall module installed and are using
    it then rules will be automatically defined for you to let traffic come from
    the exterior into the web server via port 80, and also 443 if you're using
    the apache::ssl class. (Default: false)

  * manage_munin: If you have the munin module installed and are using it, then
    some apache graphs will be configured for you. (Default: false)

  * no_default_site: If you do not want the 0-default.conf and
    0-default_ssl.conf virtualhosts automatically created in your node
    configuration. (Default: false)

  * ssl: If you want to install Apache SSL support enabled, just pass this
    parameter (Default: false)

For example:

    class { 'apache':
      manage_shorewall => true,
      manage_munin     => true,
      no_default_site  => true,
      ssl              => true
    }

You can install the ITK worker model to enforce stronger, per-user security:

    include apache::itk

On CentOS you can include 'apache::itk_plus' to get that mode. Not currently
implemented for other operating systems

You can combine SSL support and the ITK worker model by including both classes.


Configuring Apache
------------------

To deploy a configuration files to the conf.d or include.d directory under
Apache's config directory, you can use the following:

    apache::config::file { 'filename':
      content => 'Alias /thisApplication /usr/share/thisApplication/htdocs',
    }

by default this will deploy a conf.d global configuration file called 'filename'
with that content.

You can pass the parameter 'type => include' to add includes for vhosts


To manage users in an htpasswd file:

    apache::htpasswd_user { "joe@$domain":
      ensure             => present,   # default: present
      site               => "$domain", # default: 'absent' - will use $name
      username           => 'joe',     # default: 'absent' - will use $name
      password           => "pass",
      password_iscrypted => false,     # default: false - will sha1 hash the value
      path               => 'absent'   # default: 'absent' - /var/www/htpasswds/${site}
    }

This will place an encrypted version of "pass" for user joe into
/var/www/htpasswds/${site}

You will need to make sure that ${site} exists before this is done, see the
apache::vhost class below for how this is done.

VirtualHost files
-----------------

vhosts can be added with the apache::vhost define.

You can ship a flat file containing the configuration, or a template. That is
controlled by the 'vhost_mode' parameter, which can be either 'file', or
'template' (default).

Unless specified, the source will be automatically pulled from
modules/site_apache/{templates,files}/vhosts.d, searched in this order:

    "puppet:///modules/site_apache/vhosts.d/${::fqdn}/${name}.conf",
    "puppet:///modules/site_apache/vhosts.d/{$apache::cluster_node}/${name}.conf",
    "puppet:///modules/site_apache/vhosts.d/${::operatingsystem}.${::operatingsystemmajrelease}/${name}.conf",
    "puppet:///modules/site_apache/vhosts.d/${::operatingsystem}/${name}.conf",
    "puppet:///modules/site_apache/vhosts.d/${name}.conf",

otherwise you can pass a 'content' parameter to configure a template location that
it should be pulled from, or a 'vhost_source' parameter to specify the file source.

For example:

This would deploy a the vhost for $domain, pulled from a file from the sources
listed above:

    apache::vhost { "$domain": vhost_mode => 'file' }

    apache::vhost { "$domain":
                       vhost_mode   => 'file',
                       vhost_source => 'modules/site_configs/vhosts.d/${name}.conf"
    }

There are multiple other additional configurables that you can pass to each
vhost definition:

* logmode:
   - default: Do normal logging to CustomLog and ErrorLog
   - nologs: Send every logging to /dev/null
   - anonym: Don't log ips for CustomLog, send ErrorLog to /dev/null
   - semianonym: Don't log ips for CustomLog, log normal ErrorLog

* run_mode: controls in which mode the vhost should be run, there are different setups
            possible:
    - normal: (*default*) run vhost with the current active worker (default: prefork) don't
              setup anything special
    - itk: run vhost with the mpm_itk module (Incompatibility: cannot be used in combination
           with 'proxy-itk' & 'static-itk' mode)
    - proxy-itk: run vhost with a dual prefork/itk setup, where prefork just proxies all the
                 requests for the itk setup, that listens only on the loobpack device.
                 (Incompatibility: cannot be used in combination with the itk setup.)
    - static-itk: run vhost with a dual prefork/itk setup, where prefork serves all the static
                  content and proxies the dynamic calls to the itk setup, that listens only on
                  the loobpack device (Incompatibility: cannot be used in combination with
                  'itk' mode)

* mod_security: Whether we use mod_security or not (will include mod_security module)
     - false: (*default*) don't activate mod_security
     - true: activate mod_security

For templates, you can pass various parameters that will automatically configure
the template accordingly (such as php_options and php_settings). Please see
manifests/vhost/template.pp for the full list.

There are various pre-made vhost configurations that use good defaults that you can use:

- apache::vhost::gitweb - sets up a gitweb vhost
- apache::vhost::modperl - uses modperl, with optional fastcgi
- apache::vhost::passenger - setup passenger
- apache::vhost::proxy - setup a proxy vhost
- apache::vhost::redirect - vhost to redirect hosts
- apache::vhost::static - a static vhost
- apache::vhost::webdav - for managing webdave accessible targets

Additionally, for php sites, there are several handy pre-made vhost configurations:

- apache::vhost::php::drupal
- apache::vhost::php::gallery2
- apache::vhost::php::global_exec_bin_dir
- apache::vhost::php::joomla
- apache::vhost::php::mediawiki
- apache::vhost::php::safe_mode_bin
- apache::vhost::php::silverstripe
- apache::vhost::php::simplemachine
- apache::vhost::php::spip
- apache::vhost::php::standard
- apache::vhost::php::typo3
- apache::vhost::php::webapp
- apache::vhost::php::wordpress
