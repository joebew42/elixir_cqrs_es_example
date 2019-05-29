defmodule Bank.Http.Router do
  use Plug.Router

  alias Bank.Commands

  plug :match
  plug Plug.Parsers, parsers: [:json],
                     pass: ["application/json"],
                     json_decoder: Jason
  plug :dispatch

  post "/accounts" do
    %{"name" => name} = conn.body_params

    account_id = UUID.uuid5(:nil, name)

    command = %Commands.CreateAccount{
      account_id: account_id,
      name: name
    }

    case command_bus().send(command) do
      :ok ->
        conn
        |> put_resp_content_type("application/json")
        |> put_resp_header("location", "/accounts/#{account_id}")
        |> send_resp(204, "")

      _ ->
        send_resp(conn, 500, "Error while creating the account")
    end
  end

  defp command_bus() do
    Application.get_env(:elixir_cqrs_es_example, :command_bus)
  end
end
