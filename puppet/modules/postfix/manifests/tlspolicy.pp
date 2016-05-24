#
# == Class: postfix::tlspolicy
#
# Manages Postfix TLS policy by merging policy snippets configured
# via postfix::tlspolicy_snippet defines
#
# Parameters:
# - $fingerprint_digest (defaults to sha1)
#
# Note that this class is useless when used directly.
# The postfix::tlspolicy_snippet defines takes care of importing
# it anyway.
#
class postfix::tlspolicy(
  $fingerprint_digest = 'sha1'
) {

  include common::moduledir
  common::module_dir{'postfix/tls_policy': }

  $postfix_tlspolicy_dir          = "${common::moduledir::module_dir_path}/postfix/tls_policy"
  $postfix_merged_tlspolicy       = "${postfix_tlspolicy_dir}/merged_tls_policy"

  concat { "$postfix_merged_tlspolicy":
    require => File[$postfix_tlspolicy_dir],
    owner   => root,
    group   => root,
    mode    => '0600',
  }

  postfix::hash { '/etc/postfix/tls_policy':
    source    => "$postfix_merged_tlspolicy",
    subscribe => File["$postfix_merged_tlspolicy"],
  }

  postfix::config {
    'smtp_tls_fingerprint_digest': value => "$fingerprint_digest";
  }

  postfix::config { 'smtp_tls_policy_maps':
    value   => 'hash:/etc/postfix/tls_policy',
    require => [
                Postfix::Hash['/etc/postfix/tls_policy'],
                Postfix::Config['smtp_tls_fingerprint_digest'],
               ],
  }

  # Cleanup previous implementation's internal files
  file { "${postfix_tlspolicy_dir}/tls_policy.d":
    ensure  => absent,
    recurse => true,
    force   => true,
  }

}
