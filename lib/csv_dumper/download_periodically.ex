defmodule CsvDumper.DownloadPeriodically do
  use GenServer

  @download_url 'http://spatialkeydocs.s3.amazonaws.com/FL_insurance_sample.csv.zip'


  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def init(state) do
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, state) do
    #start download
    IO.puts "...download start..."
    do_download_csv_file()
    IO.puts "...download done..."
    schedule_work()

    {:noreply, state}
  end

  defp schedule_work() do
    # 2 hours = 2(hours) * 60(minutes) * 60(seconds) * 1000(milliseconds)
    # 5 minutes = 5(minutes) * 60(seconds) * 1000(milliseconds)
    Process.send_after(self(), :work, 1*60*1000) # In 1 minute
  end

  defp do_download_csv_file do
    {:ok, resp} = :httpc.request(:get, {@download_url, []}, [], [body_format: :binary])
    IO.inspect resp
    {{_, 200, 'OK'}, _headers, body} = resp
    File.write!("data_csv/FL_sample.csv.zip", body)
  end

end
