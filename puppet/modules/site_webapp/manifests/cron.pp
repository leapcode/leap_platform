class site_webapp::cron {

  # cron tasks that need to be performed to cleanup the database
  cron {
    'remove_expired_sessions':
      command     => 'bundle exec rake cleanup:sessions',
      cwd         => '/srv/leap/webapp',
      environment => 'RAILS_ENV=production',
      hour        => 2,
      minute      => 30;

    'remove_expired_tokens':
      command     => 'bundle exec rake cleanup:tokens',
      cwd         => '/srv/leap/webapp',
      environment => 'RAILS_ENV=production',
      hour        => 3,
      minute      => 0;
  }
}
