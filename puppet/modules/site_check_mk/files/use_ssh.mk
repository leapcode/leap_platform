# http://mathias-kettner.de/checkmk_datasource_programs.html
datasource_programs = [
 ( "ssh -l root -i /etc/check_mk/.ssh/id_rsa <IP> check_mk_agent", ALL_HOSTS ),
]

