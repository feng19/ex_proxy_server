import Config

config :logger, level: :info
config :logger, :console, format: "$date $time [$level] $message\n"
