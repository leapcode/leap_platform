class sshd::redhat inherits sshd::linux {
    Package[openssh]{
        name => 'openssh-server',
    }
}
