defmodule BeamBot.Workflow do
  @moduledoc false
  require Logger

  alias BeamBot.Ports

  defstruct [:owner, :repo, :issue_number, :issue_link, :sender, :command, :branch]

  @type t :: %__MODULE__{
          owner: String.t(),
          repo: String.t(),
          issue_number: integer(),
          issue_link: String.t(),
          sender: String.t(),
          command: String.t(),
          branch: String.t()
        }

  @spec parse(map()) ::
          {:ok, BeamBot.Workflow.t()}
          | {:error, :not_a_command}
          | {:error, :could_not_parse_command, BeamBot.Workflow.t()}
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

      {:error, :not_a_command} ->
        {:error, :not_a_command}

      _ ->
        {:error, :could_not_parse_command, workflow}
    end
  end
end
