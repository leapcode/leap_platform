# common/manifests/modules_dir.pp -- create a default directory
# for storing module specific information
#
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

# A module_dir is a storage place for all the stuff a module might want to
# store. According to the FHS, this should go to /var/lib. Since this is a part
# of puppet, the full path is /var/lib/puppet/modules/${name}. Every module
# should # prefix its module_dirs with its name.
#
# Usage:
# include common::moduledir
# module_dir { ["common", "common/dir1", "common/dir2" ]: }
#
# You may refer to a file in module_dir by using :
# file { "${common::moduledir::module_dir_path}/somedir/somefile": }
define common::module_dir(
  $owner = root,
  $group = 0,
  $mode = 0644
) {
  include common::moduledir
  file {
    "${common::moduledir::module_dir_path}/${name}":
      ensure    => directory,
      recurse   => true,
      purge     => true,
      force     => true,
      owner     => $owner,
      group     => $group,
      mode      => $mode;
  }
}
