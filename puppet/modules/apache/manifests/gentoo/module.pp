define apache::gentoo::module(
    $ensure = present,
    $source = '',
    $destination = ''
){
    $modules_dir = "${apache::gentoo::config_dir}/modules.d"
    $real_destination = $destination ? {
        '' => "${modules_dir}/${name}.conf",
        default => $destination,
    }
    $real_source = $source ? {
        ''  => [
            "puppet:///modules/site_apache/modules.d/${::fqdn}/${name}.conf",
            "puppet:///modules/site_apache/modules.d/${apache::cluster_node}/${name}.conf",
            "puppet:///modules/site_apache/modules.d/${name}.conf",
            "puppet:///modules/apache/modules.d/${::operatingsystem}/${name}.conf",
            "puppet:///modules/apache/modules.d/${name}.conf"
        ],
        default => "puppet:///$source",
    }
    file{"modules_${name}.conf":
        ensure => $ensure,
        path => $real_destination,
        source => $real_source,
        require => [ File[modules_dir], Package[apache] ],
        notify => Service[apache],
        owner => root, group => 0, mode => 0644;
    }
}

