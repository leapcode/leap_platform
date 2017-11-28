# Default parameters
class site_config::params {

  $ip_address               = hiera('ip_address')
  $ip_address_interface     = getvar("interface_${ip_address}")
  $ec2_local_ipv4_interface = getvar("interface_${::ec2_local_ipv4}")
  $environment              = hiera('environment', undef)

  if str2bool("$::vagrant") {
    # Depending on the backend hypervisor networking is setup differently.
    if $::interfaces =~ /eth1/ {
      # Virtualbox: Private networking creates a second interface eth1
      $interface = 'eth1'
    }
    else {
      # KVM/Libvirt: Private networking is done by defauly on first interface
      $interface = 'eth0'
    }
    include site_config::packages::build_essential
  }
  elsif hiera('interface','') != '' {
    $interface = hiera('interface')
  }
  elsif $ip_address_interface != '' {
    $interface = $ip_address_interface
  }
  elsif $ec2_local_ipv4_interface != '' {
    $interface = $ec2_local_ipv4_interface
  }
  elsif $::interfaces =~ /eth0/ {
    $interface = 'eth0'
  }
  else {
    fail("unable to determine a valid interface, please set a valid interface for this node in nodes/${::hostname}.json")
  }

  $ca_name              = 'leap_ca'
  $client_ca_name       = 'leap_client_ca'
  $ca_bundle_name       = 'leap_ca_bundle'
  $cert_name            = 'leap'
  $commercial_ca_name   = 'leap_commercial_ca'
  $commercial_cert_name = 'leap_commercial'
}
