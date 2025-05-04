defmodule BeamBot.JWT do
  @moduledoc """
  Module to handle JWT creation for github authentication
  """

  use Joken.Config

  @impl true
  def token_config do
    default_claims(skip: [:aud, :nbf])
  end

  def signer do
    priv_path = :code.priv_dir(:beambot) |> to_string()
    # TODO: Get this key from a File Storage instead of the server priv directory
    private_key_name = System.get_env("PRIVATE_KEY_NAME")
    private_key_path = priv_path <> "/keys" <> private_key_name

    priv_key = File.read!(private_key_path)
    Joken.Signer.create("RS256", %{"pem" => priv_key})
  end

  @doc """
  Gera um token com claims e jti (JWT ID único).
  """
  def generate_token(claims \\ %{}) do
    now = DateTime.utc_now() |> DateTime.add(-1, :minute) |> DateTime.to_unix()
    exp = DateTime.utc_now() |> DateTime.add(9, :minute) |> DateTime.to_unix()

    claims =
      claims
      |> Map.put("iat", now)
      |> Map.put("exp", exp)
      |> Map.put("iss", "Iv23liKOlQdJEYAUUNnL")

    generate_and_sign(claims, signer())
  end
end
