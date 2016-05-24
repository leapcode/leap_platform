define apache::file(
    $owner = root,
    $group = 0,
    $mode = 0640
) {
    file{$name:
# as long as there are significant memory problems using
# recurse we avoid it
#        recurse => true,
        backup => false,
        checksum => undef,
        owner => $owner, group => $group, mode => $mode;
    }
}

