defmodule Beambot.DeployLock.Services.VerifyLockTest do
  use Beambot.DataCase, async: true
  alias BeamBot.DeployLock.Services.VerifyLock

  describe "execute/2" do
    test "should return unlock if the pr number is the same" do
      insert(:deploy_lock)

      assert {:ok, :unlock} = VerifyLock.execute("office", 2)
    end

    test "should return lock if the pr number is different" do
      insert(:deploy_lock)

      assert {:ok, :lock} = VerifyLock.execute("office", 3)
    end

    test "should return unlock if it have no lock" do
      assert {:ok, :unlock} = VerifyLock.execute("office", 3)
    end
  end
end
