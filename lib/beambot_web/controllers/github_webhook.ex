defmodule BeambotWeb.GithubWebhook do
  use BeambotWeb, :controller

  alias BeamBot.Genservers.DeployManager

  def webhook(conn, params) do
    case BeamBot.Workflow.parse(params) do
      {:ok, workflow} ->
        process_name = to_string(workflow.issue_number)
        DeployManager.start_process(process_name, workflow)
        send_resp(conn, 200, "ok")

      {:error, :not_a_command} ->
        send_resp(conn, 200, "ok")

      {:error, :could_not_parse_command, workflow} ->
        message = BeamBot.Responses.unknown_command()
        BeamBot.Ports.Provider.create_comment(workflow.owner, workflow.repo, workflow.issue_number, message)
        send_resp(conn, 200, "ok")
    end
  end
end
