class passenger::munin {

  case $passenger_memory_munin_config { '':
    { $passenger_memory_munin_config = "user root\nenv.passenger_memory_stats /usr/sbin/passenger-memory-stats" }
  }

  case $passenger_stats_munin_config { '':
    { $passenger_stats_munin_config = "user root\n" }
  }

  munin::plugin::deploy {
    'passenger_memory_stats':
      source => 'passenger/munin/passenger_memory_stats',
      config => $passenger_memory_munin_config;
    'passenger_stats':
      source => 'passenger/munin/passenger_stats',
      config => $passenger_stats_munin_config;
  }

}
