define rubygems::brokengem($source,$ensure) {
    exec { "get-gem-$name":
        command => "/usr/bin/wget --output-document=/tmp/$name.gem $source",
        creates => "/tmp/$name.gem",
        before => Package[$name]
    }
    package{$name:
        ensure => $ensure,
        provider => gem,
        source => "/tmp/$name.gem"
    }
}

# $Id$
