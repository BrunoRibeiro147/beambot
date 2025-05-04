defmodule Beambot.DeployEvent.Services.CreateDeployEvent do
  @moduledoc false

  alias BeamBot.Schemas.DeployEvent

  def execute(status, pr_number, environment, action, user) do
    %{
      environment: environment,
      action: action,
      user: user,
      status: status,
      pr_number: pr_number
    }
    |> DeployEvent.changeset()
    |> Beambot.Repo.insert()
  end
end
