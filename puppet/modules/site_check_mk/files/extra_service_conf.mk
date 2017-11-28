# retry 3 times before setting a service into a hard state
# Delay a hard state of the APT check for 1 day
# so unattended_upgrades has time to upgrade packages.
#
extra_service_conf["max_check_attempts"] = [
  ("360", ALL_HOSTS , ["APT"] ),
  ("4", ALL_HOSTS , ALL_SERVICES )
]

#
# run check_mk_agent every 4 minutes if it terminates successfully.
# see https://leap.se/code/issues/6539 for the rationale
#
extra_service_conf["normal_check_interval"] = [
  ("4", ALL_HOSTS , "Check_MK" )
]
