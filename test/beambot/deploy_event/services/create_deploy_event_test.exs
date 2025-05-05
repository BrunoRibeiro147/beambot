defmodule Beambot.DeployEvent.Services.CreateDeployEventTest do
  use Beambot.DataCase, async: true

  alias Beambot.DeployEvent.Services.CreateDeployEvent
  alias BeamBot.Schemas.DeployEvent

  describe "execute/5" do
    test "should create an deploy event if params are valid" do
      assert {:ok, %DeployEvent{}} = CreateDeployEvent.execute("in_progress", 2, "office", "deploy", "BrunoRibeiro147")
    end

    test "should return an error if status it's not supported" do
      assert {:error, %Ecto.Changeset{valid?: false}} = CreateDeployEvent.execute("invalid", 2, "office", "deploy", "BrunoRibeiro147")
    end
  end
end
