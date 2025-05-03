defmodule BeamBot.DeployLock.Services.DeleteLock do
  alias BeamBot.Schemas.DeployLock
  alias Beambot.Repo
  alias BeamBot.DeployLock.Services.GetLock

  def execute(environment, unlocked_by) do
    with {:ok, deploy_lock} <- GetLock.execute(environment),
         true <- deploy_lock.locked_by == unlocked_by do
      Repo.delete(deploy_lock)
    else
      false ->
        {:error, :user_not_allowed_to_unlock,
         Repo.get_by(DeployLock, %{environment: environment})}

      error ->
        error
    end
  end
end
