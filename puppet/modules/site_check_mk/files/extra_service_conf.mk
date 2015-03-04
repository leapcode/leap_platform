# retry 3 times before setting a service into a hard state
# and send out notification
extra_service_conf["max_check_attempts"] = [
  ("4", ALL_HOSTS , ALL_SERVICES )
]

#
# run check_mk_agent every 2 minutes if it terminates successfully.
# see https://leap.se/code/issues/6539 for the rationale
#
# update: temporarily set interval to 60 minutes until we solve the
#         issue with the users db getting bloated with deleted
#         test users.
#
extra_service_conf["normal_check_interval"] = [
  ("60", ALL_HOSTS , "Check_MK" )
]

