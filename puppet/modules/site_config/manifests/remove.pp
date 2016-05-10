# remove leftovers from previous deploys
class site_config::remove {
  include site_config::remove::files

  case $::operatingsystemrelease {
    /^8.*/: {
      include site_config::remove::jessie
    }
    default:  { }
  }
}
