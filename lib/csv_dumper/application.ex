defmodule CsvDumper.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Redix, name: :redix},
      {CsvDumper.DownloadPeriodically, []},
      {CsvDumper.FromCsvToRedis, []},
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: CsvDumper.ApiEndpoint,
        options: [port: cowboy_port()]
      )
    ]

    opts = [strategy: :one_for_one, name: CsvDumper.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp cowboy_port, do: Application.get_env(:csv_dumper, :cowboy_port)
end
