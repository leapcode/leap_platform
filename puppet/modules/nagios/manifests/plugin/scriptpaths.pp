class nagios::plugin::scriptpaths {
    case $::hardwaremodel {
    	x86_64: { $script_path =  "/usr/lib64/nagios/plugins/" }
    	default: { $script_path =  "/usr/lib/nagios/plugins" }
    }
}
