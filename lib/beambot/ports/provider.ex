defmodule BeamBot.Ports.Provider do
  @moduledoc """
  Interface for interacting with the git cloud provider
  """

  @callback parse_webhook(payload :: map()) :: map()
  @callback create_comment(
              owner :: String.t(),
              repo :: String.t(),
              pr_id :: integer(),
              message :: String.t()
            ) :: {:ok, :comment_created} | {:error, :comment_not_created}
  @callback create_authentication_token(jwt_token :: String.t()) ::
              {:ok, String.t()} | {:error, :could_not_create_token}

  def parse_webhook(payload) do
    adapter().parse_webhook(payload)
  end

  def create_comment(owner, repo, pr_id, message) do
    adapter().create_comment(owner, repo, pr_id, message)
  end

  def create_authentication_token(jwt_token) do
    adapter().create_authentication_token(jwt_token)
  end

  defp adapter do
    Application.get_env(:beambot, __MODULE__)[:adapter]
  end
end
