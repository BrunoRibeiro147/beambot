defmodule BeamBot.Genservers.DeployManager do
  use GenServer

  require Logger
  alias BeamBot.Ports.Provider

  def create_workflow_process(payload) do
    {:ok, pid} = start_link(payload)
    GenServer.cast(pid, :parse_command)
  end

  def start_link(payload) do
    GenServer.start_link(__MODULE__, %{payload: payload})
  end

  @impl true
  def init(state) do
    environments = %{
      "office" => "us-east-1-office_deploy",
      "cubex" => "us-east-1-int-cubex_deploy"
    }

    state = Map.put(state, :environments, environments)

    {:ok, state}
  end

  @impl true
  def handle_cast(:parse_command, state) do
    case BeamBot.Workflow.parse(state.payload) do
      {:ok, workflow} ->
        handle_workflow_command(workflow)
        {:noreply, Map.put(state, :workflow, workflow)}

      {:error, :could_not_parse_command, workflow} ->
        message = BeamBot.Responses.unknown_command()
        Provider.create_comment(workflow.owner, workflow.repo, workflow.issue_number, message)
        {:noreply, state}
    end
  end

  @impl true
  def handle_info(:deploy, state) do
    %{
      owner: owner,
      repo: repo,
      issue_number: issue_number,
      issue_link: issue_link,
      command: command,
      sender: sender
    } = state.workflow

    environment = command.environment
    action = "deploy"

    Task.start(fn ->
      Beambot.DeployEvent.Services.CreateDeployEvent.execute(
        "in_process",
        issue_number,
        environment,
        action,
        sender
      )
    end)

    with {:ok, :unlock} <-
           BeamBot.DeployLock.Services.VerifyLock.execute(environment, issue_number),
         message <-
           BeamBot.Responses.success_deploy(environment, issue_number, issue_link, action, sender) do
      Logger.warning("Deployed success")
      Provider.create_comment(owner, repo, issue_number, message)

      Beambot.DeployEvent.Services.CreateDeployEvent.execute(
        "deployed",
        issue_number,
        environment,
        action,
        sender
      )
    else
      {:ok, :lock} ->
        message =
          BeamBot.Responses.failed_deploy(
            :lock,
            environment,
            issue_number,
            issue_link,
            action,
            sender
          )

        Provider.create_comment(owner, repo, issue_number, message)
    end

    {:noreply, state}
  end

  @impl true
  def handle_info(:lock, state) do
    %{
      owner: owner,
      repo: repo,
      issue_number: issue_number,
      issue_link: issue_link,
      command: command,
      sender: sender
    } = state.workflow

    environment = command.environment

    case BeamBot.DeployLock.Services.CreateLock.execute(
           environment,
           issue_number,
           sender,
           command.reason
         ) do
      {:ok, _deploy_lock} ->
        message =
          BeamBot.Responses.success_lock(environment, issue_number, issue_link, "lock", sender)

        Beambot.DeployEvent.Services.CreateDeployEvent.execute(
          "created",
          issue_number,
          environment,
          "lock",
          sender
        )

        Provider.create_comment(owner, repo, issue_number, message)

      {:error, :environment_already_locked} ->
        message = BeamBot.Responses.failed_lock(:environment_already_locked)
        Provider.create_comment(owner, repo, issue_number, message)

      _ ->
        :error
    end

    {:noreply, state}
  end

  @impl true
  def handle_info(:unlock, state) do
    %{
      owner: owner,
      repo: repo,
      issue_number: issue_number,
      issue_link: issue_link,
      command: command,
      sender: sender
    } = state.workflow

    environment = command.environment

    case BeamBot.DeployLock.Services.DeleteLock.execute(environment, sender) do
      {:ok, _deploy_lock} ->
        message =
          BeamBot.Responses.success_unlock(
            environment,
            issue_number,
            issue_link,
            "unlock",
            sender
          )

        Provider.create_comment(owner, repo, issue_number, message)

      {:error, :user_not_allowed_to_unlock, deploy_lock} ->
        message =
          BeamBot.Responses.failed_unlock(:user_not_allowed_to_unlock, deploy_lock.locked_by)

        Provider.create_comment(owner, repo, issue_number, message)

      {:error, :lock_not_found} ->
        message = BeamBot.Responses.failed_unlock(:lock_not_found)
        Provider.create_comment(owner, repo, issue_number, message)
    end

    {:noreply, state}
  end

  @impl true
  def handle_info(:help, state) do
    workflow = state.workflow
    message = BeamBot.Responses.help_message()

    Provider.create_comment(workflow.owner, workflow.repo, workflow.issue_number, message)

    {:noreply, state}
  end

  defp handle_workflow_command(%{command: %BeamBot.Actions.Deploy{}}), do: send(self(), :deploy)
  defp handle_workflow_command(%{command: %BeamBot.Actions.Lock{}}), do: send(self(), :lock)
  defp handle_workflow_command(%{command: %BeamBot.Actions.Unlock{}}), do: send(self(), :unlock)
  defp handle_workflow_command(%{command: %BeamBot.Actions.Help{}}), do: send(self(), :help)
end
