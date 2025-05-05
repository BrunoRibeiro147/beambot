defmodule Beambot.DeployLock.Services.GetLockTest do
  use Beambot.DataCase, async: true

  alias BeamBot.DeployLock.Services.GetLock
  alias BeamBot.Schemas.DeployLock

  describe "execute/1" do
    test "should return an lock if exists" do
      insert(:deploy_lock)

      assert {:ok, %DeployLock{}} = GetLock.execute("office")
    end

    test "should return an error if lock does not exists" do
      assert {:error, :lock_not_found} = GetLock.execute("office")
    end
  end
end
