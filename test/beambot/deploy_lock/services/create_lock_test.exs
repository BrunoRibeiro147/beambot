defmodule Beambot.DeployLock.Services.CreateLockTest do
  use Beambot.DataCase, async: true

  alias BeamBot.DeployLock.Services.CreateLock
  alias BeamBot.Schemas.DeployLock

  describe "execute/4" do
    test "should create an lock if all params are valid" do
      assert {:ok, %DeployLock{}} = CreateLock.execute("office", 2, "BrunoRibeiro147", "test")
    end

    test "should return an error if a lock already exists for the environment" do
      CreateLock.execute("office", 2, "BrunoRibeiro147", "test")

      assert {:error, :environment_already_locked} =
               CreateLock.execute("office", 4, "BrunoRibeiro147", "another test")
    end
  end
end
