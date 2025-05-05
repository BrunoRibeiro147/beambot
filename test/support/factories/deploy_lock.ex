defmodule BeamBot.Factories.DeployLock do
  @moduledoc false

  use ExMachina.Ecto, repo: Beambot.Repo

  alias BeamBot.Schemas.DeployLock

  defmacro __using__(_opts) do
    quote do
      def deploy_lock_factory do
        %DeployLock{
          pr_number: 2,
          environment: "office",
          locked_by: "BrunoRibeiro147",
          reason: "test"
        }
      end
    end
  end
end
