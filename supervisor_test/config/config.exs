import Config

config :logger,
  level: :info

config :supervisor_test_app,
  request_interval: 100,
  request_num_range: 1..999,
  worker_bad_state_divider: 50,
  worker_bad_state_range: 10..30,
  worker_init_state: 1000,
  workers_count: 10,
  worker_sup_max_restarts: 3,
  worker_sup_max_seconds: 5,
  emitter_enabled: true

import_config "#{config_env()}.exs"
