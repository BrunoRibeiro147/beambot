defmodule BeambotWeb.GithubWebhook do
  use BeambotWeb, :controller

  alias BeamBot.Genservers.DeployManager

  def webhook(conn, params) do
    # payload = Map.get(params, "payload")
    command = get_in(params, ["comment", "body"])

    case BeamBot.CommandParser.is_a_bot_command?(command) do
      true ->
        DeployManager.create_workflow_process(params)
        send_resp(conn, 200, "ok")

      false ->
        send_resp(conn, 200, "ok")
    end
  end
end
