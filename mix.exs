defmodule CsvDumper.MixProject do
  use Mix.Project

  def project do
    [
      app: :csv_dumper,
      version: "0.1.0",
      elixir: "~> 1.8.1",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :redix, :exq, :exq_ui, :tzdata],
      mod: {CsvDumper.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
     {:plug_cowboy, "~> 2.0.2"},
      # {:poison, "~> 3.1.0"},
      # Plug : HTTP get and JSON
      # {:httpoison, "~> 1.5.1"},
      # {:json, "~> 0.3.3"},
      # Redis cache
      {:redix, ">= 0.10.2"},
      {:poison, "~> 3.1.0"},
      {:exq, ">= 0.13.3"},
      {:exq_ui, "~> 0.10.0"},
      {:tzdata, "~> 1.0.1"},
      {:jason, "~> 1.1.2"},

    ]
  end
end
