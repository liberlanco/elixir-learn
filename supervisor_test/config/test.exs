import Config

config :logger,
  level: :debug

config :supervisor_test_app,
  request_interval: 10,
  workers_count: 0,
  emitter_enabled: false
