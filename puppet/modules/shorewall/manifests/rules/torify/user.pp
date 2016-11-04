define shorewall::rules::torify::user(
  $originaldest = '-',
  $allow_rfc1918 = true
){

  $user = $name

  include shorewall::rules::torify::allow_tor_transparent_proxy

  if $originaldest == '-' and $user == '-' {
    include shorewall::rules::torify::allow_tor_user
  }

  shorewall::rules::torify::redirect_tcp_to_tor {
    "redirect-to-tor-user=${user}-to=${originaldest}":
      user         => $user,
      originaldest => $originaldest
  }

  shorewall::rules::torify::reject_non_tor {
    "reject-non-tor-user=${user}-to=${originaldest}":
      user          => "$user",
      originaldest  => $originaldest,
      allow_rfc1918 => $allow_rfc1918;
  }

}
