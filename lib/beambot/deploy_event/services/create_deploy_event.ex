defmodule Beambot.DeployEvent.Services.CreateDeployEvent do
  @moduledoc false

  alias BeamBot.Schemas.DeployEvent

  def execute(status, pr_number, environment, action, user, reason \\ "") do
    %{
      environment: environment,
      action: action,
      user: user,
      status: status,
      pr_number: pr_number,
      reason: reason
    }
    |> DeployEvent.changeset()
    |> Beambot.Repo.insert()
  end
end
