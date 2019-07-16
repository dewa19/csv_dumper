defmodule ExqRedisWorker do
  alias CsvDumper

  def perform(key, value) do
    CsvDumper.do_save_into_redis(key, value)
    # IO.puts("save data into redis : #{key}")
  end
end
