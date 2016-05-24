# Class: augeas::files
#
# Sets up directories and files for Augeas
#
class augeas::files {
  $lens_dir = $augeas::lens_dir

  # ensure no file not managed by puppet ends up in there.
  file { $lens_dir:
    ensure       => directory,
    purge        => $::augeas::purge,
    force        => true,
    recurse      => true,
    recurselimit => 1,
    mode         => '0644',
    owner        => 'root',
    group        => 'root',
  }

  file { "${lens_dir}/dist":
    ensure => directory,
    purge  => false,
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
  }

  file { "${lens_dir}/tests":
    ensure => directory,
    purge  => $::augeas::purge,
    force  => true,
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
  }
}
