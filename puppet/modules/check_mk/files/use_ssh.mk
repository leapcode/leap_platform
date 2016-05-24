# http://mathias-kettner.de/checkmk_datasource_programs.html
datasource_programs = [
 ( "ssh -l root -i /omd/sites/monitoring/.ssh/monitoring_<HOST>_id_rsa <IP> check_mk_agent", ['ssh'], ALL_HOSTS ),
]

