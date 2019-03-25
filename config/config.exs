use Mix.Config

config :logger,
  backends: [{LoggerFileBackend, :error_log}, :console]

# configuration for the {LoggerFileBackend, :error_log} backend
config :logger, :error_log,
  path: "log/inst.log",
  format: "$date $time $metadata[$level] $levelpad$message\n",
  metadata: [:line],
  level: :info
  #level: :error

config :logger, :console,
  format: "$date $time $metadata[$level] $levelpad$message\n",
  metadata: [:line]

config :tzdata, :data_dir, "./tzdata"
