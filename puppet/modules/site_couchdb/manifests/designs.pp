class site_couchdb::designs {

  Class['site_couchdb::create_dbs']
    -> Class['site_couchdb::designs']

  file { '/srv/leap/couchdb/designs':
    ensure  => directory,
    source  => 'puppet:///modules/site_couchdb/designs',
    recurse => true,
    purge   => true,
    mode    => '0755'
  }

  #cleanup leftovers from before soledad created its db
  file {
    '/srv/leap/couchdb/designs/shared/':
    ensure  => absent,
    recurse => true,
    force   => true,
  }

  site_couchdb::upload_design {
    'customers':    design => 'customers/Customer.json';
    'identities':   design => 'identities/Identity.json';
    'tickets':      design => 'tickets/Ticket.json';
    'messages':     design => 'messages/Message.json';
    'users':        design => 'users/User.json';
    'tmp_users':    design => 'users/User.json';
    'invite_codes': design => 'invite_codes/InviteCode.json';
  }

  $sessions_db      = rotated_db_name('sessions', 'monthly')
  $sessions_next_db = rotated_db_name('sessions', 'monthly', 'next')
  site_couchdb::upload_design {
    $sessions_db:       design => 'sessions/Session.json';
    $sessions_next_db:  design => 'sessions/Session.json';
  }

  $tokens_db       = rotated_db_name('tokens', 'monthly')
  $tokens_next_db  = rotated_db_name('tokens', 'monthly', 'next')
  site_couchdb::upload_design {
    $tokens_db:      design => 'tokens/Token.json';
    $tokens_next_db: design => 'tokens/Token.json';
  }
}
