defmodule BeambotWeb.Plugs.VerifyGithubSignature do
  @moduledoc false

  import Plug.Conn

  @behaviour Plug

  def init(opts), do: opts

  def call(conn, _opts) do
    with {:ok, raw_body, _} <- Plug.Conn.read_body(conn),
         {:ok, received_signature} <- get_signature(conn),
         expected_signature <-
           generate_signature(raw_body),
         true <- Plug.Crypto.secure_compare(received_signature, expected_signature) do
      conn
    else
      _ ->
        conn
        |> send_resp(401, "Signature is missing")
        |> halt()
    end
  end

  defp get_signature(conn) do
    case get_req_header(conn, "x-hub-signature-256") do
      [] ->
        {:error, :signature_missing}

      [signature] ->
        [_, received_signature] = String.split(signature, "=")
        {:ok, received_signature}
    end
  end

  defp generate_signature(payload) do
    secret = Application.get_env(:beambot, :github_webhook_secret)

    :crypto.mac(:hmac, :sha256, secret, payload)
    |> Base.encode16(case: :lower)
  end
end
