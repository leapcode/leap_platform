# retry 3 times before setting a service into a hard state
# and send out notification
extra_service_conf["max_check_attempts"] = [
  ("4", ALL_HOSTS , ALL_SERVICES )
]

#
# run check_mk_agent every 4 minutes if it terminates successfully.
# see https://leap.se/code/issues/6539 for the rationale
#
extra_service_conf["normal_check_interval"] = [
  ("4", ALL_HOSTS , "Check_MK" )
]

