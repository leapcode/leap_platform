# shorewall::rules::torify
#
# Note: shorewall::rules::torify cannot be used several times with the
# same user listed in the $users array. This restriction applies to
# using this define multiple times without providing a $users
# parameter.
#
# Parameters:
#
# - users: every element of this array must be valid in shorewall
#   rules user/group column.
# - destinations: every element of this array must be valid in
#   shorewall rules original destination column.

define shorewall::rules::torify(
  $users        = ['-'],
  $destinations = ['-'],
  $allow_rfc1918 = true
){

  $originaldest = join($destinations,',')

  shorewall::rules::torify::user {
    $users:
      originaldest  => $originaldest,
      allow_rfc1918 => $allow_rfc1918;
  }

}
