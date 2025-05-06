defmodule Beambot.CommandParserTest do
  use Beambot.DataCase, async: true

  describe "parse/1" do
    test "should sucessfully parse an command" do
      assert {:ok, %BeamBot.Actions.Deploy{environment: "office"}} =
               BeamBot.CommandParser.parse("/beambot deploy office")
    end

    test "should return an error if command requires an environement and it's missing" do
      assert {:error, [environment: {"can't be blank", [validation: :required]}]} =
               BeamBot.CommandParser.parse("/beambot deploy")
    end

    test "should return an error if the environment is not supported" do
      assert {:error,
              [
                environment:
                  {"is invalid", [{:validation, :inclusion}, {:enum, ["cubex", "office"]}]}
              ]} = BeamBot.CommandParser.parse("/beambot deploy test")
    end

    test "should sucessufly parse an help command" do
      assert {:ok, %BeamBot.Actions.Help{}} = BeamBot.CommandParser.parse("/beambot help")
    end

    test "should return an error when the command does not exist" do
      assert :error = BeamBot.CommandParser.parse("/beambot super_test")
    end

    test "should return an error when the command is not passed" do
      assert {:error, :invalid_format} = BeamBot.CommandParser.parse("/beambot")
    end

    test "should return an error when is not a command" do
      assert {:error, :not_a_command} = BeamBot.CommandParser.parse("test")
    end
  end
end
