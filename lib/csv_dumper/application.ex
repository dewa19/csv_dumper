defmodule CsvDumper.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false


  use Application
  #alias CsvDumper.DownloadPeriodically

  def start(_type, _args) do
    children = [
      # Starts a worker by calling: CsvDumper.Worker.start_link(arg)
      # {CsvDumper.Worker, arg}
      {Redix, name: :redix},
      #{CsvDumper.DownloadPeriodically,[]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CsvDumper.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
