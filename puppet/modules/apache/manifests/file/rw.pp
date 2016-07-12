# a file that is writable by apache
define apache::file::rw(
  $owner  = root,
  $group  = 0,
  $mode   = '0660',
) {
  apache::file{$name:
    owner => $owner,
    group => $group,
    mode  => $mode,
  }
}

