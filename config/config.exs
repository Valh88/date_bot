# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

# config :tesla, adapter: Tesla.Adapter.Gun

config :ex_gram,
  token: "6622260946:AAErrswzp6RxwYXxulFzhCLP028Hw608tJs",
  adapter: ExGram.Adapter.Tesla

# middlewares: [
#   {TeslaMiddlewares, :retry, []}
# ]

config :database, Database.Repo,
  database: "database_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 5432,
  # show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :database, ecto_repos: [Database.Repo]
# Sample configuration:
#
#     config :logger, :console,
#       level: :info,
#       format: "$date $time [$level] $metadata$message\n",
#       metadata: [:user_id]
#
import_config "#{config_env()}.exs"
