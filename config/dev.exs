use Mix.Config

# Настройки базы данных
config :database, Database.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "database_repo",
  hostname: "localhost",
  pool_size: 10
