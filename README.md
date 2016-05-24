# Puppet SSH Module

[![Build Status](https://travis-ci.org/duritong/puppet-sshd.png?branch=master)](https://travis-ci.org/duritong/puppet-sshd)

This puppet module manages OpenSSH configuration and services.

**!! Upgrade Notice (05/2015) !!**

The hardened_ssl parameter name was changed to simply 'hardened'.

**!! Upgrade Notice (01/2013) !!**

This module now uses parameterized classes, where it used global variables
before. So please whatch out before pulling, you need to change the
class declarations in your manifest !


### Dependencies

This module requires puppet => 2.6, and the following modules are required
pre-dependencies:

- [puppetlabs/stdlib](https://github.com/puppetlabs/puppetlabs-stdlib) >= 2.x

## OpenSSH Server

On a node where you wish to have an openssh server installed, you should
include

```puppet
class { 'sshd': }
```

on that node. If you need to configure any aspects of sshd_config, set the variables before the include. Or you can adjust many parameters:

```puppet
class { 'sshd':
  ports             => [ 20002 ],
  permit_root_login => 'no',
}
```

See Configurable Variables below for what you can set.

### Nagios

To have nagios checks setup automatically for sshd services, simply set
`manage_nagios` to `true` for that class. If you want to disable ssh
nagios checking for a particular node (such as when ssh is firewalled), then you
can set the class parameter `nagios_check_ssh` to `false` and that node will not be
monitored.

Nagios will automatically check the ports defined in `ports`, and the
hostname specified by `nagios_check_ssh_hostname`.

Note that if you need to use some specific logic to decide whether or not to
create a nagios service check, you should set $manage_nagios to false, and
use sshd::nagios from within your own manifests. You'll also need to manually
specify the port to that define. By default, if the $port parameter is not
specified, it will use the resource name as the port (e.g. if you call it like
this: `sshd::nagios { '22': }` )

NOTE: this requires that you are using the shared-nagios puppet module which
supports the nagios native types via `nagios::service`:

https://gitlab.com/shared-puppet-modules-group/sshd

### Firewall

If you wish to have firewall rules setup automatically for you, using shorewall,
you will need to set: `use_shorewall => true`. The `ports` that you have
specified will automatically be used.

NOTE: This requires that you are using the shared-shorewall puppet module:
git://labs.riseup.net/shared-shorewall


### Configurable variables

Configuration of sshd is strict, and may not fit all needs, however there are a
number of variables that you can consider configuring. The defaults are set to
the distribution shipped sshd_config file defaults.

To set any of these variables, simply set them as variables in your manifests,
before the class is included, for example:

```puppet
class {'sshd':
  listen_address => ['10.0.0.1', '192.168.0.1'],
  use_pam        => yes
}
```

If you need to install a version of the ssh daemon or client package other than
the default one that would be installed by `ensure => installed`, then you can
set the following variables:

```puppet
class {'sshd':
  ensure_version => "1:5.2p2-6"
}
```

The following is a list of the currently available variables:

  - `listen_address`
        specify the addresses sshd should listen on set this to `['10.0.0.1', '192.168.0.1']` to have it listen on both addresses, or leave it unset to listen on all Default: empty -> results in listening on `0.0.0.0`
  - `allowed_users`
    list of usernames separated by spaces.  set this for example to `"foobar
    root"` to ensure that only user foobar and root might login.  Default: empty
    -> no restriction is set
  - `allowed_groups`
    list of groups separated by spaces. set this for example to `"wheel sftponly"`
    to ensure that only users in the groups wheel and sftponly might login.
    Default: empty -> no restriction is set Note: This is set after
    `allowed_users`, take care of the behaviour if you use these 2 options
    together.
  - `use_pam` if you want to use pam or not for authenticaton. Values:
    - `no` (default)
    - `yes`
  - `permit_root_login` If you want to allow root logins or not. Valid values:
    - `yes`
    - `no`
    - `without-password` (default)
    - `forced-commands-only`
  - `password_authentication`
    If you want to enable password authentication or not. Valid values:
    - `yes`
    - `no` (default)
  - `kerberos_authentication`
    If you want the password that is provided by the user to be validated
    through the Kerberos KDC. To use this option the server needs a Kerberos
    servtab which allows the verification of the KDC's identity. Valid values:
    - `yes`
    - `no` (default)
  - `kerberos_orlocalpasswd` If password authentication through Kerberos fails, then the password will be validated via any additional local mechanism.  Valid values:
    - `yes` (default)
    - `no`
  - `kerberos_ticketcleanup` Destroy the user's ticket cache file on logout?  Valid values:
    - `yes` (default)
    - `no`
  - `gssapi_authentication` Authenticate users based on GSSAPI? Valid values:
    - `yes`
    - `no` (default)
  - `gssapi_cleanupcredentials` Destroy user's credential cache on logout? Valid values:
    - `yes` (default)
    - `no`
  - `challenge_response_authentication` If you want to enable ChallengeResponseAuthentication or not When disabled, s/key passwords are disabled. Valid values:
    - `yes`
    - `no` (default)
  - `tcp_forwarding` If you want to enable TcpForwarding. Valid values:
    - `yes`
    - `no` (default)
  - `x11_forwarding` If you want to enable x11 forwarding. Valid values:
    - `yes`
    - `no` (default)
  - `agent_forwarding` If you want to allow ssh-agent forwarding. Valid values:
    - `yes`
    - `no` (default)
  - `pubkey_authentication` If you want to enable public key authentication. Valid values:
    - `yes` (default)
    - `no`
  - `rsa_authentication` If you want to enable RSA Authentication. Valid values:
    - `yes`
    - `no` (default)
  - `rhosts_rsa_authentication`
    If you want to enable rhosts RSA Authentication. Valid values:
    - `yes`
    - `no` (default)
  - `hostbased_authentication` If you want to enable `HostbasedAuthentication`. Valid values:
    - `yes`
    - `no` (default)
  - `strict_modes` If you want to set `StrictModes` (check file modes/ownership before accepting login). Valid values:
    - `yes` (default)
    - `no`
  - `permit_empty_passwords`
    If you want enable PermitEmptyPasswords to allow empty passwords. Valid
    Values:
    - `yes`
    - `no` (default)
  - `ports` If you want to specify a list of ports other than the default `22`; Default: `[22]`
  - `authorized_keys_file`
    Set this to the location of the AuthorizedKeysFile
    (e.g. `/etc/ssh/authorized_keys/%u`). Default: `AuthorizedKeysFile
    %h/.ssh/authorized_keys`
  - `hardened`
    Use only strong ciphers, MAC, KexAlgorithms, etc.
    Values:
    - `no` (default)
    - `yes`
  - `print_motd`
    Show the Message of the day when a user logs in.
  - `sftp_subsystem`
    Set a different sftp-subystem than the default one. Might be interesting for
    sftponly usage. Default: empty -> no change of the default
  - `head_additional_options`
    Set this to any additional sshd_options which aren't listed above. Anything
    set here will be added to the beginning of the sshd_config file. This option
    might be useful to define complicated Match Blocks. This string is going to
    be included, like it is defined. So take care! Default: empty -> not added.
  - `tail_additional_options` Set this to any additional sshd_options which aren't listed above. Anything set here will be added to the end of the sshd_config file. This option might be useful to define complicated Match Blocks. This string is going to be included, like it is defined. So take care! Default: empty -> not added.
  - `shared_ip` Whether the server uses a shared network IP address. If it does, then we don't want it to export an rsa key for its IP address. Values:
  - `no` (default)
  - `yes`


### Defines and functions

Deploy authorized_keys file with the define `authorized_key`.

Generate a public/private keypair with the ssh_keygen function. For example, the
following will generate ssh keys and put the different parts of the key into
variables:

```puppet
$ssh_keys = ssh_keygen("${$ssh_key_basepath}/backup/keys/${::fqdn}/${backup_host}")
$public_key = split($ssh_keys[1],' ')
$sshkey_type => $public_key[0]
$sshkey => $public_key[1]
```

## Client


On a node where you wish to have the ssh client managed, you can do:

```puppet
class{'sshd::client':

}
```

in the node definition. This will install the appropriate package.

## License

 - Copyright 2008-2011, Riseup Labs micah@riseup.net
 - Copyright 2008, admin(at)immerda.ch
 - Copyright 2008, Puzzle ITC GmbH
 - Marcel Härry haerry+puppet(at)puzzle.ch
 - Simon Josi josi+puppet(at)puzzle.ch

This program is free software; you can redistribute
it and/or modify it under the terms of the GNU
General Public License version 3 as published by
the Free Software Foundation.

