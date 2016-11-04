include concat::setup
include unbound
unbound::forward { 'example.com':
  settings => {
    forward-addr => '127.0.0.1',
  },
}
