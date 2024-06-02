import Config

config :database, Database.Repo,
  username: "postgres",
  password: "postgres",
  database: "database_repo",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
