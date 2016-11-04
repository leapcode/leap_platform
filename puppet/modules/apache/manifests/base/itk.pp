class apache::base::itk inherits apache::base {
    File['htpasswd_dir']{
        group => 0,
        mode => 0644,
    }
}
