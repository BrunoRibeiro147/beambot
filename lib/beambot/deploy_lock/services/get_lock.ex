defmodule BeamBot.DeployLock.Services.GetLock do
  @moduledoc false
  alias Beambot.Repo
  alias BeamBot.Schemas.DeployLock

  def execute(environment) do
    case Repo.get_by(DeployLock, %{environment: environment}) do
      nil ->
        {:error, :lock_not_found}

      deploy_lock ->
        {:ok, deploy_lock}
    end
  end
end
