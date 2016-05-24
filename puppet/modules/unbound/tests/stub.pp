include concat::setup
include unbound::params
unbound::stub { 'example.com':
  settings => {
    stub-addr => '127.0.0.1',
  },
}
