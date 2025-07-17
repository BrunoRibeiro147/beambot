defmodule BeamBot.Genservers.DeployManagerTest do
  use Beambot.DataCase

  alias BeamBot.Adapters.Providers.ProviderMock
  alias BeamBot.Genservers.DeployManager
  alias BeamBot.Workflow
  alias BeamBot.Responses
  alias BeamBot.Schemas.DeployEvent

  import Mox
  setup :verify_on_exit!

  describe "start_process/1" do
    test "should successfully deploy" do
      workflow = make(:workflow)

      expect(ProviderMock, :create_comment, fn owner, repo, issue_number, message ->
        assert owner == "BrunoRibeiro147"
        assert repo == "Beambot"
        assert issue_number == 2

        assert message ==
                 Responses.success_deploy(
                   "office",
                   issue_number,
                   workflow.issue_link,
                   "deploy",
                   "BrunoRibeiro147"
                 )

        {:ok, :comment_created}
      end)

      pr_number = "1"

      assert {:ok, pid} = DeployManager.start_link(String.to_atom(pr_number))

      allow(ProviderMock, self(), pid)

      GenServer.cast(pid, {:start_process, workflow})

      assert %{
               status: :in_process,
               workflow: ^workflow,
               environments: %{
                 "cubex" => "us-east-1-int-cubex_deploy",
                 "office" => "us-east-1-office_deploy"
               }
             } = :sys.get_state(pid)

      Process.sleep(100)

      assert [
               %DeployEvent{status: "in_progress", action: "deploy"},
               %DeployEvent{status: "deployed", action: "deploy"}
             ] = Beambot.Repo.all(DeployEvent)
    end

    test "should successfully deploy if the environment is locked by the deploying branch" do
      insert(:deploy_lock)

      workflow = make(:workflow)

      expect(ProviderMock, :create_comment, fn owner, repo, issue_number, message ->
        assert owner == "BrunoRibeiro147"
        assert repo == "Beambot"
        assert issue_number == 2

        assert message ==
                 Responses.success_deploy(
                   "office",
                   issue_number,
                   workflow.issue_link,
                   "deploy",
                   "BrunoRibeiro147"
                 )

        {:ok, :comment_created}
      end)

      pr_number = "1"

      assert {:ok, pid} = DeployManager.start_link(String.to_atom(pr_number))

      allow(ProviderMock, self(), pid)

      GenServer.cast(pid, {:start_process, workflow})

      assert %{
               status: :in_process,
               workflow: ^workflow,
               environments: %{
                 "cubex" => "us-east-1-int-cubex_deploy",
                 "office" => "us-east-1-office_deploy"
               }
             } = :sys.get_state(pid)

      Process.sleep(100)

      assert [
               %DeployEvent{status: "in_progress", action: "deploy"},
               %DeployEvent{status: "deployed", action: "deploy"}
             ] = Beambot.Repo.all(DeployEvent)
    end

    test "should return an error if trying to deploy and the environment is locked" do
      insert(:deploy_lock)

      workflow = make(:workflow, %{issue_number: 3})

      expect(ProviderMock, :create_comment, fn owner, repo, issue_number, message ->
        assert owner == "BrunoRibeiro147"
        assert repo == "Beambot"
        assert issue_number == 3

        assert message ==
                 Responses.failed_deploy(
                   :lock,
                   "office",
                   issue_number,
                   workflow.issue_link,
                   "deploy",
                   "BrunoRibeiro147"
                 )

        {:ok, :comment_created}
      end)

      pr_number = "1"

      assert {:ok, pid} = DeployManager.start_link(String.to_atom(pr_number))

      allow(ProviderMock, self(), pid)

      GenServer.cast(pid, {:start_process, workflow})

      assert %{
               status: :in_process,
               workflow: ^workflow,
               environments: %{
                 "cubex" => "us-east-1-int-cubex_deploy",
                 "office" => "us-east-1-office_deploy"
               }
             } = :sys.get_state(pid)

      Process.sleep(100)

      assert [
               %DeployEvent{status: "in_progress", action: "deploy"},
               %DeployEvent{status: "failed", action: "deploy", reason: "environment is locked"}
             ] = Beambot.Repo.all(DeployEvent)
    end
  end

  def make(:workflow, params \\ %{}) do
    default_command = %BeamBot.Actions.Deploy{environment: "office"}

    %Workflow{
      owner: Map.get(params, :owner, "BrunoRibeiro147"),
      sender: Map.get(params, :sender, "BrunoRibeiro147"),
      command: Map.get(params, :command, default_command),
      repo: Map.get(params, :repo, "Beambot"),
      issue_number: Map.get(params, :issue_number, 2),
      issue_link:
        Map.get(params, :issue_link, "https://github.com/BrunoRibeiro147/Beambot/pull/2"),
      branch: Map.get(params, :branch, nil)
    }
  end
end
