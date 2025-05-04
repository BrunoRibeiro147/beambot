defmodule Beambot.WorkflowTest do
  use ExUnit.Case, async: true

  alias BeamBot.Workflow

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
          "html_url" => "https://github.com/BrunoRibeiro147/Beambot/pull/2",
          "number" => 2,
          "user" => %{
            "login" => "BrunoRibeiro147"
          }
        },
        "repository" => %{
          "name" =>  "Beambot"
        }
      }

      %{params: params}
    end

    test "should parse an valid command", %{params: params} do
      assert {:ok,
              %Workflow{
                owner: "BrunoRibeiro147",
                sender: "BrunoRibeiro147",
                command: %BeamBot.Actions.Deploy{environment: "office"},
                repo: "Beambot",
                issue_number: 2,
                issue_link: "https://github.com/BrunoRibeiro147/Beambot/pull/2",
                branch: nil
              }} = Workflow.parse(params)
    end
  end
end
