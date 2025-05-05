defmodule Beambot.DeployLock.Services.DeleteLockTest do
  use Beambot.DataCase, async: true

  alias BeamBot.DeployLock.Services.DeleteLock
  alias BeamBot.Schemas.DeployLock

  describe "execute/2" do
    test "should delete an lock" do
      insert(:deploy_lock)

      assert {:ok, %DeployLock{}} = DeleteLock.execute("office", "BrunoRibeiro147")
    end

    test "should return an error if the person trying to unlock was not the one the lock it" do
      insert(:deploy_lock)

      assert {:error, :user_not_allowed_to_unlock ,%DeployLock{}} = DeleteLock.execute("office", "Test")
    end
  end
end
