defmodule Bot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    token = ExGram.Config.get(:ex_gram, :token)
    :ets.new(:dates_cache, [:named_table, :set, :public, read_concurrency: true, write_concurrency: true])
    children = [
      # Starts a worker by calling: Bot.Worker.start_link(arg)
      # {Bot.Worker, arg}
      ExGram,
      {Bot.Bot, [token: token, method: :polling]},
      Database.Repo,
      {Registry, keys: :unique, name: Bot.Registry},
      {DynamicSupervisor, name: Bot.DynamicSupervisor, strategy: :one_for_one}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
