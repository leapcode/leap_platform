# http://mathias-kettner.de/checkmk_datasource_programs.html
datasource_programs = [
 ( "ssh -l root -i /etc/check_mk/.ssh/id_rsa <HOST> check_mk_agent", ALL_HOSTS ),
]

