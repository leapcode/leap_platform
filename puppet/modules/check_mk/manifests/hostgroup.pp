define check_mk::hostgroup (
  $dir,
  $hostgroups,
  $target,
) {
  $group = $title
  $group_tags = sprintf("'%s'", join($hostgroups[$group]['host_tags'], "', '"))
  concat::fragment { "check_mk-hostgroup-${group}":
    target  => $target,
    content => "  ( '${group}', [ ${group_tags} ], ALL_HOSTS ),\n",
    order   => 21,
  }
  if $hostgroups[$group]['description'] {
    $description = $hostgroups[$group]['description']
  }
  else {
    $description = regsubst($group, '_', ' ')
  }
  file { "${dir}/${group}.cfg":
    ensure  => present,
    content => "define hostgroup {\n  hostgroup_name ${group}\n  alias ${description}\n}\n",
    require => File[$dir],
  }
}
