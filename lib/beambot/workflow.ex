defmodule BeamBot.Workflow do
  require Logger

  alias BeamBot.Ports

  defstruct [:owner, :repo, :issue_number, :issue_link, :sender, :command, :branch]

  @spec parse(map()) ::
          {:ok, %BeamBot.Workflow{}} | {:error, :could_not_parse_command, %BeamBot.Workflow{}}
  def parse(params) do
    parsed_info = Ports.Provider.parse_webhook(params)

    workflow = %__MODULE__{
      owner: parsed_info.pr_owner,
      sender: parsed_info.sender,
      issue_number: parsed_info.issue_number,
      issue_link: parsed_info.issue_link,
      repo: parsed_info.repo,
      command: nil,
      branch: nil
    }

    case BeamBot.CommandParser.parse(parsed_info.message) do
      {:ok, command} ->
        workflow = Map.put(workflow, :command, command)
        {:ok, workflow}

      _ ->
        {:error, :could_not_parse_command, workflow}
    end
  end
end
