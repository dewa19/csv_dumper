defmodule CsvDumper.FromCsvToRedis do
  use GenServer

  alias CsvDumper

  # in minutes
  @scheduled_every 5

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, [])
  end

  def init(opts) do
    schedule_work(@scheduled_every)
    {:ok, opts}
  end

  def handle_info(:processdata, state) do
    do_process_data()
    schedule_work(@scheduled_every)
    {:noreply, state}
  end

  defp schedule_work(xminutes) do
    # 2 hours = 2(hours) * 60(minutes) * 60(seconds) * 1000(milliseconds)
    # 5 minutes = 5(minutes) * 60(seconds) * 1000(milliseconds)
    # In 1 minute
    Process.send_after(self(), :processdata, xminutes * 60 * 1000)
  end

  def print_time(event) do
    time =
      DateTime.utc_now()
      |> DateTime.to_time()
      |> Time.to_iso8601()

    IO.puts("The time is now: #{time}...#{event}...")
  end

  def do_process_data do
    print_time("Begin process data")
    CsvDumper.process_data()
    print_time("End process data")
  end
end
