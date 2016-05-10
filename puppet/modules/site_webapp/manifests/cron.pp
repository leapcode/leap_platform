# setup webapp cronjobs
class site_webapp::cron {

  # cron tasks that need to be performed to cleanup the database
  cron {
    'rotate_databases':
      command     => 'cd /srv/leap/webapp && bundle exec rake db:rotate',
      environment => 'RAILS_ENV=production',
      user        => 'root',
      hour        => [0,6,12,18],
      minute      => 0;

    'delete_tmp_databases':
      command     => 'cd /srv/leap/webapp && bundle exec rake db:deletetmp',
      environment => 'RAILS_ENV=production',
      user        => 'root',
      hour        => 1,
      minute      => 1;

    # there is no longer a need to remove expired sessions, since the database
    # will get destroyed.
    'remove_expired_sessions':
      ensure      => absent,
      command     => 'cd /srv/leap/webapp && bundle exec rake cleanup:sessions',
      environment => 'RAILS_ENV=production',
      user        => 'leap-webapp',
      hour        => 2,
      minute      => 30;

    'remove_expired_tokens':
      command     => 'cd /srv/leap/webapp && bundle exec rake cleanup:tokens',
      environment => 'RAILS_ENV=production',
      user        => 'leap-webapp',
      hour        => 3,
      minute      => 0;
  }
}
