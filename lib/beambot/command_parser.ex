defmodule BeamBot.CommandParser do
  alias BeamBot.Utils

  @valid_commands %{
    "deploy" => {BeamBot.Actions.Deploy, [:environment]},
    "lock" => {BeamBot.Actions.Lock, [:environment, :reason]},
    "unlock" => {BeamBot.Actions.Unlock, [:environment]}
  }

  def is_a_bot_command?(message) do
    String.starts_with?(message, Utils.get_bot_prefix())
  end

  @spec parse(binary()) :: {:ok, action :: map()} | {:error, any()}
  def parse(message) do
    bot_prefix = Utils.get_bot_prefix()

    cond do
      String.trim(message) == bot_prefix <> " help" ->
        {:ok, %BeamBot.Actions.Help{}}

      String.starts_with?(message, bot_prefix) ->
        with [_prefix | parts] <- String.split(message, " ", trim: true),
             [command | args] <- parts,
             {:ok, {mod, fields}} <- lookup_command(command),
             {:ok, parsed_args} <- parse_args(fields, args),
             changeset <- mod.changeset(parsed_args),
             {:ok, cmd} <- apply_changeset(changeset) do
          {:ok, cmd}
        else
          {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset.errors}
          [] -> {:error, :invalid_format}
          error -> error
        end

      true ->
        {:error, :not_a_command}
    end
  end

  defp lookup_command(cmd), do: Map.fetch(@valid_commands, cmd)

  defp parse_args(fields, raw_args) do
    {named, positional} =
      Enum.split_with(raw_args, &String.starts_with?(&1, "--"))

    named_map =
      named
      |> Enum.map(fn arg ->
        case String.split(arg, "=", parts: 2) do
          ["--" <> key, value] -> {String.to_atom(key), value}
          _ -> nil
        end
      end)
      |> Enum.reject(&is_nil/1)
      |> Enum.into(%{})

    positional_map =
      fields
      |> Enum.reject(&Map.has_key?(named_map, &1))
      |> Enum.zip(positional)
      |> Enum.into(%{})

    {:ok, Map.merge(positional_map, named_map)}
  end

  defp apply_changeset(%Ecto.Changeset{valid?: true} = changeset),
    do: {:ok, Ecto.Changeset.apply_changes(changeset)}

  defp apply_changeset(changeset),
    do: {:error, changeset}
end
