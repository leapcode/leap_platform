#
# git module
#
# Copyright 2008, Puzzle ITC
# Marcel Härry haerry+puppet(at)puzzle.ch
# Simon Josi josi+puppet(at)puzzle.ch
#
# This program is free software; you can redistribute 
# it and/or modify it under the terms of the GNU 
# General Public License version 3 as published by 
# the Free Software Foundation.
#

class git {

  case $operatingsystem {
    debian: { include git::debian }
    centos: { include git::centos }
  }

  if $use_shorewall {
    include shorewall::rules::out::git
  }

}
