defmodule CsvDumper.ApiEndpoint do
  use Plug.Router
  require Logger

  plug(Plug.Logger)

  plug(:match)

  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)

  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, "CSV Dumper : main API")
  end

  get "/policyid/:policyid" do
    resp =
      policyid
      |> fetch_from_redis

    send_resp(conn, 200, resp)
  end

  defp fetch_from_redis(policyID) do
    status = Redix.command(:redix, ["GET", policyID])

    case status do
      {:ok, result} ->
        case result do
          # not found in Redis
          nil ->
            response =
              Poison.encode!(%{
                message_type: "error",
                detail: %{
                  message: "Can't find policyID = #{policyID}",
                  reason: "Unknown key",
                  error_code: "e01"
                }
              })

          # found in Redis
          _ ->
            response =
              Poison.encode!(%{
                message_type: "ok",
                detail: Poison.decode!(result)
              })

            # response = result
        end

      {:error, error} ->
        response =
          Poison.encode!(%{
            message_type: "error",
            detail: %{
              message: "Redix command GET response with {:error, error}",
              reason: "#{error.reason}",
              error_code: "e02"
            }
          })
    end
  end

  match _ do
    no_match =
      Poison.encode!(%{code: 1, type: :error, detail: %{message: "CSV Dumper : Invalid path!"}})

    send_resp(conn, 404, no_match)
  end
end
