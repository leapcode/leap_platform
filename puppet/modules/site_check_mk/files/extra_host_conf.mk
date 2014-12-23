# retry 3 times before setting a host into a hard state
# and send out notification
extra_host_conf["max_check_attempts"] = [ 
  ("4", ALL_HOSTS ) 
]

