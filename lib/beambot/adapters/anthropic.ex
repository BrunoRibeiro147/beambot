defmodule Beambot.Adapters.Anthropic do
  require Logger

  import Tesla

  def send_message(commit_list) do
    template_message = """
    Based on the list of commits that I'm going to pass to you, I want you to analyze the patterns and return an list of Jira tickets,
    this tickets has to follow this pattern OFF-xxx, if you not find, return an empty list.

    You should response as a strict JSON no extra communication, you JSON response should follow this format:
    [
      {
        id: "OFF-xxx",
        title: "Title of the ticket",
        description: "Description of the ticket"
      }
    ]
    '''
    {commit_list}
    '''
    """

    body = %{
      model: "claude-sonnet-4-20250514",
      max_tokens: 1024,
      messages: [
        %{
          role: "user",
          content: String.replace(template_message, "{commit_list}", Jason.encode!(commit_list))
        }
      ]
    }

    client = get_client()

    case post(client, "/messages", body) do
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
      {Tesla.Middleware.BaseUrl, "https://api.anthropic.com/v1"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers,
       [
         {"x-api-key", Application.fetch_env!(:beambot, __MODULE__)[:api_key]},
         {"anthropic-version", "2023-06-01"}
       ]}
    ])
  end
end
