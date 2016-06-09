#
# == Class: postfix::transport_regexp
#
# Manages Postfix transport_regexp by merging snippets shipped:
# - in the module's files/transport_regexp.d/ or puppet:///files/etc/postfix/transport_regexp.d
#   (the latter takes precedence if present); site_postfix module is supported
#   as well, see the source argument of file {"$postfix_transport_regexp_snippets_dir"
#   bellow for details.
# - via postfix::transport_regexp_snippet defines
#
# Example usage:
# 
#   node "toto.example.com" {
#     class { 'postfix':
#       manage_transport_regexp => 'yes',
#     }
#     postfix::config { "transport_maps":
#       value => "hash:/etc/postfix/transport, regexp:/etc/postfix/transport_regexp",
#     }
#   }
#
class postfix::transport_regexp {

  include common::moduledir
  common::module_dir{'postfix/transport_regexp': }

  $postfix_transport_regexp_dir          = "${common::moduledir::module_dir_path}/postfix/transport_regexp"
  $postfix_transport_regexp_snippets_dir = "${postfix_transport_regexp_dir}/transport_regexp.d"
  $postfix_merged_transport_regexp       = "${postfix_transport_regexp_dir}/merged_transport_regexp"

  file {"$postfix_transport_regexp_snippets_dir":
    ensure  => 'directory',
    owner   => 'root',
    group   => '0',
    mode    => '700',
    source  => [
                "puppet:///modules/site_postfix/${fqdn}/transport_regexp.d",
                "puppet:///modules/site_postfix/transport_regexp.d",
                "puppet:///files/etc/postfix/transport_regexp.d",
                "puppet:///modules/postfix/transport_regexp.d",
               ],
    recurse => true,
    purge   => false,
  }

  concatenated_file { "$postfix_merged_transport_regexp":
    dir     => "${postfix_transport_regexp_snippets_dir}",
    require => File["$postfix_transport_regexp_snippets_dir"],
  }
  
  config_file { '/etc/postfix/transport_regexp':
    source    => "$postfix_merged_transport_regexp",
    subscribe => File["$postfix_merged_transport_regexp"],
  }

}
