class git::debian inherits git::base {

  Package['git'] {
    name => 'git-core',
  }
}
