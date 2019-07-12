defmodule ExqDownloadWorker do

    alias CsvDumper

    def perform do
      CsvDumper.do_download_csv_file()
      IO.puts("..download csv file..: done")
    end

end
