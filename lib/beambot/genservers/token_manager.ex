defmodule BeamBot.Genservers.TokenManager do
  use GenServer

  alias BeamBot.Ports.Provider
  alias BeamBot.JWT
  require Logger

  @table :github_token_manager

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get_installation_token(installation_id) do
    GenServer.call(__MODULE__, {:get_or_create_token, installation_id})
  end

  defp refresh_token() do
    {:ok, jwt_token, _} = JWT.generate_token()
    Provider.create_authentication_token(jwt_token)
  end

  @impl true
  def init(_state) do
    :ets.new(@table, [:named_table, :set, :protected, read_concurrency: true])

    {:ok, %{}}
  end

  @impl true
  def handle_call({:get_or_create_token, installation_id}, _from, state) do
    with [{^installation_id, token, expires_at}] <- :ets.lookup(@table, installation_id),
         {:ok, token_expiration, _} <- DateTime.from_iso8601(expires_at),
         :gt <- DateTime.compare(token_expiration, DateTime.utc_now()) do
      {:reply, {:ok, token}, state}
    else
      _ ->
        {:ok, %{"token" => installation_token, "expires_at" => expires_at}} = refresh_token()
        :ets.insert(@table, {installation_id, installation_token, expires_at})
        {:reply, {:ok, installation_token}, state}
    end
  end
end
