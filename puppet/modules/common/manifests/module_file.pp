# common/manifests/module_file.pp -- use a modules_dir to store module
# specific files
#
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

# Put a file into module-local storage.
#
# Usage:
# common::module_file { "module/file":
#     source => "puppet:///...",
#     mode   => 644,   # default
#     owner  => root,  # default
#     group  => 0,     # default
# }
define common::module_file (
  $ensure = present,
  $source = undef,
  $owner  = root,
  $group  = 0,
  $mode   = 0644
){
  include common::moduledir
  file {
    "${common::moduledir::module_dir_path}/${name}":
      ensure  => $ensure,
  }

  if $ensure != 'absent' {
    File["${common::moduledir::module_dir_path}/${name}"]{
      source  => $source,
      owner   => $owner,
      group   => $group,
      mode    => $mode,
    }
  }
}
