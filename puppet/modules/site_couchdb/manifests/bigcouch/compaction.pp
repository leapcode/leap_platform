class site_couchdb::bigcouch::compaction {
  cron {
    'compact_all_shards':
      command     => '/srv/leap/couchdb/scripts/bigcouch_compact_all_shards.sh >> /var/log/bigcouch/compaction.log',
      hour        => 3,
      minute      => 17;
  }
}
