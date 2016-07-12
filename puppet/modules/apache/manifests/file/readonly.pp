define apache::file::readonly(
    $owner = root,
    $group = 0,
    $mode = 0640
) {
    apache::file{$name:
        owner => $owner,
        group => $group,
        mode => $mode,
    }
}

