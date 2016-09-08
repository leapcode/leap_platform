# ignore NTP Time because this check was
# very flaky in the past (see https://leap.se/code/issues/6407)
ignored_services += [
  ( ALL_HOSTS, [ "NTP Time" ] )
]
