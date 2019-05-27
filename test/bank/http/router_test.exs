defmodule Bank.Http.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import Mox

  alias Bank.Commands
  alias Bank.CommandBusMock, as: CommandBus

  alias Bank.Http.Router

  @opts Router.init([])

  describe "POST /accounts" do
    test "returns 204 and the resource location when succeed" do
      expected_account_id = UUID.uuid5(nil, "Foo")

      expect(CommandBus, :send, fn %Commands.CreateAccount{
                                     account_id: ^expected_account_id,
                                     name: "Foo"
                                   } ->
        :ok
      end)

      payload = """
      {
        "name": "Foo"
      }
      """

      conn = post_as_json(Router, "/accounts", payload)

      verify!(CommandBus)

      assert response(conn) == %{
               "content-type" => ["application/json; charset=utf-8"],
               "location" => ["/accounts/#{expected_account_id}"],
               "status" => 204,
               "body" => ""
             }
    end

    test "returns 500 when fails" do
      expect(CommandBus, :send, fn _ -> :nothing end)

      payload = """
      {
        "name": "Foo"
      }
      """

      conn = post_as_json(Router, "/accounts", payload)

      verify!(CommandBus)

      assert response(conn) == %{
               "content-type" => [],
               "location" => [],
               "status" => 500,
               "body" => "Error while creating the account"
             }
    end
  end

  defp post_as_json(router, path, payload) do
    conn(:post, path, payload)
    |> put_req_header("content-type", "application/json")
    |> router.call(@opts)
  end

  defp response(conn) do
    %{
      "content-type" => get_resp_header(conn, "content-type"),
      "location" => get_resp_header(conn, "location"),
      "status" => conn.status,
      "body" => conn.resp_body
    }
  end
end
