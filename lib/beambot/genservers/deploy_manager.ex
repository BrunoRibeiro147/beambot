defmodule BeamBot.Genservers.DeployManager do
  use GenServer, restart: :transient

  require Logger
  alias BeamBot.Ports.Provider

  def start_process(name, workflow) do
    {:ok, pid} = start_child(name)
    GenServer.cast(pid, {:start_process, workflow})
  end

  def start_child(name) do
    DynamicSupervisor.start_child(:dynamic_deploy_sup, {__MODULE__, name})
  end

  def start_link(name) do
    GenServer.start_link(__MODULE__, %{}, name: name)
  end

  @impl true
  def init(state) do
    environments = BeamBot.Environments.environments()

    state = Map.put(state, :environments, environments)

    {:ok, state}
  end

  @impl true
  def handle_cast({:start_process, workflow}, state) do
    state =
      state
      |> Map.put(:workflow, workflow)
      |> Map.put(:status, :in_process)

    case workflow do
      %{command: %BeamBot.Actions.Deploy{}} -> send(self(), :deploy)
      %{command: %BeamBot.Actions.Lock{}} -> send(self(), :lock)
      %{command: %BeamBot.Actions.Unlock{}} -> send(self(), :unlock)
      %{command: %BeamBot.Actions.Help{}} -> send(self(), :help)
    end

    {:noreply, state}
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

    {:stop, :normal, state}
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

    {:stop, :normal, state}
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

    {:stop, :normal, state}
  end

  @impl true
  def handle_info(:help, state) do
    workflow = state.workflow
    message = BeamBot.Responses.help_message()

    Provider.create_comment(workflow.owner, workflow.repo, workflow.issue_number, message)

    {:stop, :normal, state}
  end
end
