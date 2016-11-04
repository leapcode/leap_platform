class apache::package::itk inherits apache::package {
    Package['apache'] {
        name => 'apache2-itk',
    }
}
