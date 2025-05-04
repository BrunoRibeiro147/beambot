defmodule BeambotWeb.Plugs.ValidateEvent do
  @moduledoc """
  Module to parse the payload and validates if it's a correct event sended from the provider
  """

  import Plug.Conn
  require Logger

  @behaviour Plug

  def init(opts), do: opts

  def call(conn, _opts) do
    with event <- mount_event(conn),
         {:action_validation, true} <- {:action_validation, supported_action?(event)},
         {:user_validation, true} <- {:user_validation, user?(conn)} do
      conn
    else
      {:action_validation, false} ->
        Logger.warning("Not supported event: #{mount_event(conn)}")

        conn
        |> send_resp(200, "do not process unsupported event")
        |> halt()

      {:user_validation, false} ->
        conn
        |> send_resp(200, "do not process bot action")
        |> halt()
    end
  end

  defp mount_event(conn) do
    github_event = get_req_header(conn, "x-github-event")
    action = get_in(conn, [Access.key!(:params), "action"])

    "#{github_event}.#{action}"
  end

  defp user?(conn) do
    type = get_in(conn, [Access.key!(:params), "sender", "type"])

    case type do
      "User" -> true
      "Bot" -> false
    end
  end

  defp supported_action?("issue_comment.created"), do: true
  defp supported_action?(_), do: false
end
