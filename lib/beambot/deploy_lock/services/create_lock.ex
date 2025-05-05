defmodule BeamBot.DeployLock.Services.CreateLock do
  @moduledoc false

  alias BeamBot.DeployLock.Services.GetLock
  alias Beambot.Repo
  alias BeamBot.Schemas.DeployLock

  def execute(environment, pr_number, locked_by, reason) do
    with {:error, :lock_not_found} <- GetLock.execute(environment),
         %Ecto.Changeset{valid?: true} = changeset <-
           apply_changeset(environment, pr_number, locked_by, reason) do
      Repo.insert(changeset)
    else
      {:ok, _lock} ->
        {:error, :environment_already_locked}

      changeset ->
        {:error, changeset}
    end
  end

  defp apply_changeset(environment, pr_number, locked_by, reason) do
    %{
      environment: environment,
      pr_number: pr_number,
      locked_by: locked_by,
      reason: reason
    }
    |> DeployLock.changeset()
  end
end
