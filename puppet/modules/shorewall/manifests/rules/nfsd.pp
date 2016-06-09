class shorewall::rules::nfsd {
    shorewall::rule { 'net-me-portmap-tcp':
        source          => 'net',
        destination     => '$FW',
        proto           => 'tcp',
        destinationport => '111',
        order           => 240,
        action          => 'ACCEPT';
    }
    shorewall::rule { 'net-me-portmap-udp':
        source          => 'net',
        destination     => '$FW',
        proto           => 'udp',
        destinationport => '111',
        order           => 240,
        action          => 'ACCEPT';
    }
    shorewall::rule { 'net-me-rpc.statd-tcp':
        source          => 'net',
        destination     => '$FW',
        proto           => 'tcp',
        destinationport => '662',
        order           => 240,
        action          => 'ACCEPT';
    }
    shorewall::rule { 'net-me-rpc.statd-udp':
        source          => 'net',
        destination     => '$FW',
        proto           => 'udp',
        destinationport => '662',
        order           => 240,
        action          => 'ACCEPT';
    }
    shorewall::rule { 'me-net-rpc.statd-tcp':
        source          => 'net',
        destination     => '$FW',
        proto           => 'tcp',
        destinationport => '2020',
        order           => 240,
        action          => 'ACCEPT';
    }
    shorewall::rule { 'me-net-rpc.statd-udp':
        source          => 'net',
        destination     => '$FW',
        proto           => 'udp',
        destinationport => '2020',
        order           => 240,
        action          => 'ACCEPT';
    }
    shorewall::rule { 'net-me-rpc.lockd-tcp':
        source          => 'net',
        destination     => '$FW',
        proto           => 'tcp',
        destinationport => '32803',
        order           => 240,
        action          => 'ACCEPT';
    }
    shorewall::rule { 'net-me-rpc.lockd-udp':
        source          => 'net',
        destination     => '$FW',
        proto           => 'udp',
        destinationport => '32769',
        order           => 240,
        action          => 'ACCEPT';
    }
    shorewall::rule { 'net-me-rpc.mountd-tcp':
        source          => 'net',
        destination     => '$FW',
        proto           => 'tcp',
        destinationport => '892',
        order           => 240,
        action          => 'ACCEPT';
    }
    shorewall::rule { 'net-me-rpc.mountd-udp':
        source          => 'net',
        destination     => '$FW',
        proto           => 'udp',
        destinationport => '892',
        order           => 240,
        action          => 'ACCEPT';
    }
    shorewall::rule { 'net-me-rpc.rquotad-tcp':
        source          => 'net',
        destination     => '$FW',
        proto           => 'tcp',
        destinationport => '875',
        order           => 240,
        action          => 'ACCEPT';
    }
    shorewall::rule { 'net-me-rpc.rquoata-udp':
        source          => 'net',
        destination     => '$FW',
        proto           => 'udp',
        destinationport => '875',
        order           => 240,
        action          => 'ACCEPT';
    }
    shorewall::rule { 'net-me-rpc.nfsd-tcp':
        source          => 'net',
        destination     => '$FW',
        proto           => 'tcp',
        destinationport => '2049',
        order           => 240,
        action          => 'ACCEPT';
    }
    shorewall::rule { 'net-me-rpc.nfsd-udp':
        source          => 'net',
        destination     => '$FW',
        proto           => 'udp',
        destinationport => '2049',
        order           => 240,
        action          => 'ACCEPT';
    }

}
