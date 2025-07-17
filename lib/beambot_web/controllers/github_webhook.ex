defmodule BeambotWeb.GithubWebhook do
  @moduledoc false
  use BeambotWeb, :controller

  alias BeamBot.Genservers.DeployManager
  alias BeamBot.Ports.Provider

  def webhook(conn, params) do
    case BeamBot.Workflow.parse(params) do
      {:ok, workflow} ->
        process_name = "deploy_process_" <> to_string(workflow.issue_number)
        DeployManager.start_process(process_name, workflow)
        send_resp(conn, 200, "ok")

      {:error, :not_a_command} ->
        send_resp(conn, 200, "ok")

      {:error, :could_not_parse_command, workflow} ->
        message = BeamBot.Responses.unknown_command()

        Provider.create_comment(
          workflow.owner,
          workflow.repo,
          workflow.issue_number,
          message
        )

        send_resp(conn, 200, "ok")
    end
  end
end
