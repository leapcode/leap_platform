#
# resolvconf module
#
# Copyright 2008, admin(at)immerda.ch
# Copyright 2008, Puzzle ITC GmbH
# Marcel Härry haerry+puppet(at)puzzle.ch
# Simon Josi josi+puppet(at)puzzle.ch
#
# This program is free software; you can redistribute 
# it and/or modify it under the terms of the GNU 
# General Public License version 3 as published by 
# the Free Software Foundation.
#

class resolvconf(
  $domain = $::domain,  
  $search = $::domain,
  $nameservers = [ '8.8.8.8' ]
) {
  file{'/etc/resolv.conf':
    content => $::operatingsystem ? {
      openbsd => template("resolvconf/resolvconf.${::operatingsystem}.erb"),
      default => template('resolvconf/resolvconf.erb'),
    },
    owner => root, group => 0, mode => 0444;
  }
}
