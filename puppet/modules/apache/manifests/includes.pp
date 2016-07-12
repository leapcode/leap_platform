# manifests/includes.pp

class apache::includes {
    apache::config::global{'do_includes.conf':}
}
