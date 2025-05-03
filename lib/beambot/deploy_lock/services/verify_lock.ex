defmodule BeamBot.DeployLock.Services.VerifyLock do
  alias BeamBot.DeployLock.Services.GetLock

  def execute(environment, issue_number) do
    with {:ok, deploy_lock} <- GetLock.execute(environment),
         true <- deploy_lock.pr_number == issue_number do
      {:ok, :unlock}
    else
      false -> {:ok, :lock}
      {:error, :lock_not_found} -> {:ok, :unlock}
    end
  end
end
