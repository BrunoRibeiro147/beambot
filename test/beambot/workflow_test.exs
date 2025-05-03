defmodule Beambot.WorkflowTest do
  use ExUnit.Case, async: true

  alias Beambot.Workflow

  describe "parse/1" do
    setup do
      params = %{
        "comment" => %{
          "body" => "/beambot deploy office"
        },
        "sender" => %{
          "login" => "BrunoRibeiro147"
        },
        "issue" => %{
          "user" => %{
            "login" => "BrunoRibeiro147"
          }
        }
      }

      %{params: params}
    end

    test "should parse an valid command", %{params: params} do
      assert {:ok,
              %Beambot.Workflow{
                pr_owner: "BrunoRibeiro147",
                sender: "BrunoRibeiro147",
                action: %BeamBot.Actions.Deploy{environment: "office"},
                branch: nil
              }} = Workflow.parse(params)
    end
  end
end
