defmodule AshHq.MixProject do
  use Mix.Project

  def project do
    [
      app: :ash_hq,
      version: "0.1.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {AshHq.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # {:ash, "~> 1.52.0-rc.18"},
      {:ash, github: "ash-project/ash", override: true},
      # {:ash, path: "../ash", override: true},
      # {:ash_postgres, "~> 0.42.0-rc.5"},
      {:ash_postgres, github: "ash-project/ash_postgres"},
      # {:ash_postgres, path: "../ash_postgres"},
      {:ash_phoenix, github: "ash-project/ash_phoenix"},
      {:earmark, "~> 1.5.0-pre1", override: true},
      {:surface, "~> 0.7.3"},
      {:surface_heroicons, "~> 0.6.0"},
      # Syntax Highlighting
      {:makeup, "~> 1.1"},
      {:makeup_elixir, "~> 0.16.0"},
      {:makeup_graphql, "~> 0.1.2"},
      {:makeup_erlang, "~> 0.1.1"},
      {:makeup_eex, "~> 0.1.1"},
      {:makeup_js, "~> 0.1.0"},
      {:makeup_sql, "~> 0.1.0"},
      # Phoenix/Core dependencies
      {:phoenix, "~> 1.6.6"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.6"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.17.5"},
      {:nimble_options, "~> 0.4.0", override: true},
      {:finch, "~> 0.10.2"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.6"},
      {:esbuild, "~> 0.3", runtime: Mix.env() == :dev},
      {:swoosh, "~> 1.3"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.18"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:elixir_sense, github: "elixir-lsp/elixir_sense"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      seed: ["run priv/repo/seeds.exs"],
      setup: ["ash_postgres.create", "ash_postgres.migrate", "seed"],
      reset: ["drop", "setup"],
      drop: ["ash_postgres.drop"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.deploy": [
        "cmd --cd assets npm run deploy",
        "esbuild default --minify",
        "phx.digest"
      ]
    ]
  end
end
