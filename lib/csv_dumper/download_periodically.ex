defmodule CsvDumper.DownloadPeriodically do
  use GenServer
  @download_url "http://spatialkeydocs.s3.amazonaws.com/FL_insurance_sample.csv.zip"
  @csv_folder "data_csv"
  @downloaded_path Path.join([File.cwd!(), "#{@csv_folder}/FL_insurance_sample.zip"])
  @log_file_path "log/csv_dumper.log"

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, [])
  end

  def init(opts) do
    schedule_work(1)
    {:ok, opts}
  end

  def handle_info(:download, state) do
    do_download_csv_file()
    do_unzip_csv_file()
    # IO.puts("The time is now: #{time}...unzip & delete zip file...")
    schedule_work(1)
    {:noreply, state}
  end

  defp schedule_work(xminutes) do
    # 2 hours = 2(hours) * 60(minutes) * 60(seconds) * 1000(milliseconds)
    # 5 minutes = 5(minutes) * 60(seconds) * 1000(milliseconds)
    # In 1 minute
    Process.send_after(self(), :download, xminutes * 60 * 1000)
  end

  def print_time(event) do
    time =
      DateTime.utc_now()
      |> DateTime.to_time()
      |> Time.to_iso8601()

    IO.puts("The time is now: #{time}...#{event}...")
  end

  def do_download_csv_file do
    print_time("download")
    resp = HTTPoison.get!(@download_url)
    File.write!(@downloaded_path, resp.body)
  end

  def do_unzip_csv_file do
    print_time("unzip & delete")
    # {:ok, ["data_csv/FL_insurance_sample.csv","data_csv/__MACOSX/._FL_insurance_sample.csv"]}
    unzip_status =
      :zip.unzip('#{@csv_folder}/FL_insurance_sample.zip', [{:cwd, "#{@csv_folder}/"}])

    case unzip_status do
      {:ok, status} ->
        File.rm("#{@csv_folder}/FL_insurance_sample.zip")
        File.rm_rf("#{@csv_folder}/__MACOSX")

      {:error, _} ->
        raise "Error unzip file"
    end
  end

  def write_log(message) do
  end
end
