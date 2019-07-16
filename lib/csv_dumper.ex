defmodule CsvDumper do
  @csv_data "data_csv/FL_insurance_sample.csv"

  def process_data do
    load_data()
    |> parse_data
    |> save_into_redis
  end

  def load_data do
    [_header | data_rows] = File.read!(@csv_data) |> String.split("\r")

    data_rows
  end

  def save_into_redis(data) do
    Enum.each(data, fn pairs ->
      case pairs do
        # EOF
        [""] ->
          :skip_do_nothing

        _ ->
          the_key = List.to_string(Map.keys(pairs))
          the_value = Map.values(pairs)

          [
            [
              statecode,
              county,
              eq_site_limit,
              hu_site_limit,
              fl_site_limit,
              fr_site_limit,
              tiv_2011,
              tiv_2012,
              eq_site_deductible,
              hu_site_deductible,
              fl_site_deductible,
              fr_site_deductible,
              point_latitude,
              point_longitude,
              line,
              construction,
              point_granularity
            ]
          ] = the_value

          values_into_redis =
            Poison.encode!(%{
              policyID: "#{the_key}",
              locations: %{
                statecode: "#{statecode}",
                county: "#{county}",
                point_latitude: "#{point_latitude}",
                point_longitude: "#{point_longitude}",
                line: "#{line}",
                construction: "#{construction}",
                point_granularity: "#{point_granularity}"
              },
              siteinfo: %{
                eq_site_limit: "#{eq_site_limit}",
                hu_site_limit: "#{hu_site_limit}",
                fl_site_limit: "#{fl_site_limit}",
                fr_site_limit: "#{fr_site_limit}",
                tiv_2011: "#{tiv_2011}",
                tiv_2012: "#{tiv_2012}",
                eq_site_deductible: "#{eq_site_deductible}",
                hu_site_deductible: "#{hu_site_deductible}",
                fl_site_deductible: "#{fl_site_deductible}",
                fr_site_deductible: "#{fr_site_deductible}"
              }
            })

          Exq.enqueue(Exq, "redis", ExqRedisWorker, [the_key, values_into_redis])
      end

      # end_case
    end)

    # end_Enum.each
  end

  def do_save_into_redis(key, value) do
    Redix.command(:redix, ["SET", key, value])
  end

  def parse_data(data_rows) do
    map_row = Map.new()

    data_rows
    |> Enum.map(fn row -> String.split(String.trim(row), ",") end)
    |> Enum.map(fn row_1 ->
      with [
             policyID,
             statecode,
             county,
             eq_site_limit,
             hu_site_limit,
             fl_site_limit,
             fr_site_limit,
             tiv_2011,
             tiv_2012,
             eq_site_deductible,
             hu_site_deductible,
             fl_site_deductible,
             fr_site_deductible,
             point_latitude,
             point_longitude,
             line,
             construction,
             point_granularity
           ] <- row_1 do
        map_row =
          Map.put(map_row, policyID, [
            statecode,
            county,
            eq_site_limit,
            hu_site_limit,
            fl_site_limit,
            fr_site_limit,
            tiv_2011,
            tiv_2012,
            eq_site_deductible,
            hu_site_deductible,
            fl_site_deductible,
            fr_site_deductible,
            point_latitude,
            point_longitude,
            line,
            construction,
            point_granularity
          ])

        map_row
      else
        err -> err
      end
    end)
  end
end
