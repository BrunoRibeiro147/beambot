defmodule BeamBot.Factory do
@moduledoc """
  Core applications factories (ExMachina)
  """

  use ExMachina.Ecto, repo: Beambot.Repo

  use BeamBot.Factories.DeployLock
end
