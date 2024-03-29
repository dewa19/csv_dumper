use Mix.Config

config :exq,
  name: Exq,
  host: "127.0.0.1",
  port: 6379,
  # password: "optional_redis_auth",
  namespace: "exq",
  concurrency: :infinite,
  queues: ["redis"],
  poll_timeout: 50,
  scheduler_poll_timeout: 200,
  scheduler_enable: true,
  max_retries: 5,
  shutdown_timeout: 5000

config :exq_ui,
  host: "127.0.0.1",
  web_port: 4040,
  webnamespace: "exq_ui",
  server: true

config :csv_dumper,
  cowboy_port: 5050
