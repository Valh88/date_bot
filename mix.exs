defmodule DateBot.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    [
      {:ecto_sql, "~> 3.11.2"},
      {:postgrex, "~> 0.18.0"},
      {:ex_gram, "~> 0.52.2"},
      {:tesla, "~> 1.9"},
      {:hackney, "~> 1.20.1"},
      {:jason, ">= 1.0.0"}
    ]
  end
end
