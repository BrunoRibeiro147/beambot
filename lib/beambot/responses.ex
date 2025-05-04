defmodule BeamBot.Responses do
  @moduledoc false
  alias BeamBot.Utils

  def unknown_command do
    """
    Whoops! I don't recognize that command 🐐💥. Try #{Utils.get_bot_prefix()} help to see what I can actually do!
    """
  end

  def success_deploy(environment, pr_number, pr_link, action, user) do
    """
    ✅ **Deployment completed successfully!**

    Here are the details of the operation:

    #{render_operation_table(environment, pr_number, pr_link, action, user)}

    #{render_footer()}
    """
  end

  def failed_deploy(:lock, environment, pr_number, pr_link, action, user) do
    """
    🚫 **Deployment failed!**

    The branch is locked. Here are the details of the operation:

    #{render_operation_table(environment, pr_number, pr_link, action, user)}

    #{render_footer()}
    """
  end

  def failed_deploy(:merge_conflicts) do
    """
    🚫 **Deployment failed!**

    We hit a roadblock – this branch has merge conflicts with the target branch and can't be deployed until they are resolved.

    Please resolve the conflicts and try again.

    #{render_footer()}
    """
  end

  def success_lock(environment, pr_number, pr_link, action, user) do
    """
    ✅ **#{String.capitalize(environment)} was locked successfully!**

    Here are the details of the operation:

    #{render_operation_table(environment, pr_number, pr_link, action, user)}

    #{render_footer()}
    """
  end

  def failed_lock(:environment_already_locked) do
    """
    🚫 **Lock failed!**

    We hit a roadblock – this enviroment is already locked

    #{render_footer()}
    """
  end

  def success_unlock(environment, pr_number, pr_link, action, user) do
    """
    ✅ **#{String.capitalize(environment)} was unlocked successfully!**

    Here are the details of the operation:

    #{render_operation_table(environment, pr_number, pr_link, action, user)}

    #{render_footer()}
    """
  end

  def failed_unlock(:user_not_allowed_to_unlock, locked_by) do
    """
    ❌ **Unlock Failed!**

    Sorry, you don’t have permission to unlock this environment 🔒🙅‍♂️
    Only #{locked_by} can perform this action.

    #{render_footer()}
    """
  end

  def failed_unlock(:lock_not_found) do
    """
    ❌ **Unlock Failed!**

    No lock found for this environment

    #{render_footer()}
    """
  end

  defp render_operation_table(environment, pr_number, pr_link, action, user) do
    """
    | Status   |   User   |   Action   |  Environment   |  PR Number                  |
    | :------: | :------: | :--------: | :-----------:  | :-------------------------: |
    | Deployed | #{user}  | #{action}  | #{environment} |  [#{pr_number}](#{pr_link}) |
    """
  end

  defp render_footer do
    "Need anything else? Just call me with `#{Utils.get_bot_prefix()}` 🐐"
  end

  def help_message do
    bot_name = Utils.get_bot_name()
    bot_prefix = Utils.get_bot_prefix()

    """
    🐐 #{String.capitalize(bot_name)} - Available Commands:

    `#{bot_prefix} deploy <environment>`
      Create a deploy on the specified environment. Ex: `#{bot_prefix} deploy staging`

    `#{bot_prefix} lock <environment> [--reason=motivo]`
      Lock the deploy in the environment. Ex: `#{bot_prefix} lock staging --reason="testing"`

    `#{bot_prefix} unlock <environment>`
      Unlock the deploy in the environment. Ex: `#{bot_prefix} unlock staging`

    `#{bot_prefix} help`
      Show this help message
    """
  end
end
