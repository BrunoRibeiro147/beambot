defmodule Beambot.Adapters.Jira do
  require Logger
  import Tesla

  def create_release() do
    client = get_client()

    body = %{
      archived: false,
      description: "An excellent version",
      name: "New Version 1",
      projectId: 10000,
      releaseDate: "2010-07-06",
      released: true
    }

    case post(client, "/version", body) do
      {:ok, %Tesla.Env{status: 200, body: response}} ->
        content = List.first(response["content"])

        {:ok, Map.get(content, "text")}

      {:ok, %Tesla.Env{status: status, body: body}} ->
        Logger.error(%{status: status, body: body})
        {:error, "Error when sending the user message"}

      {:error, error} ->
        Logger.error(%{error: error})
        {:error, "Error when sending the user message"}
    end
  end

  defp get_client() do
    Tesla.client([
      {Tesla.Middleware.BaseUrl, "https://your-domain.atlassian.net/rest/api/3"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers,
       [
         {"x-api-key", Application.fetch_env!(:beambot, __MODULE__)[:api_key]},
         {"anthropic-version", "2023-06-01"}
       ]}
    ])
  end
end
