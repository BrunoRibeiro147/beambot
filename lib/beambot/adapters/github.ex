defmodule BeamBot.Adapters.Providers.Github do
  @behaviour BeamBot.Ports.Provider

  import Tesla

  require Logger
  alias BeamBot.Genservers.TokenManager

  @impl true
  def create_comment(owner, repo, issue_number, message) do
    installation_id = get_installation_id()
    {:ok, token} = TokenManager.get_installation_token(installation_id)

    client = get_client(token)

    case post(client, "repos/#{owner}/#{repo}/issues/#{issue_number}/comments", %{body: message}) do
      {:ok, %Tesla.Env{status: 201}} ->
        {:ok, :comment_created}

      error ->
        Logger.error("Error when try to create a comment: #{inspect(error)}")
        {:error, :comment_not_created}
    end
  end

  @impl true
  def parse_webhook(payload) do
    sender = get_in(payload, ["sender", "login"])
    pr_owner = get_in(payload, ["issue", "user", "login"])
    issue_number = get_in(payload, ["issue", "number"])
    issue_link = get_in(payload, ["issue", "html_url"])
    repo = get_in(payload, ["repository", "name"])
    message = get_in(payload, ["comment", "body"])

    %{
      sender: sender,
      pr_owner: pr_owner,
      issue_number: issue_number,
      issue_link: issue_link,
      repo: repo,
      message: message
    }
  end

  @impl true
  def create_authentication_token(jwt_token) do
    installation_id = get_installation_id()
    client = get_client(jwt_token)

    case post(client, "app/installations/#{installation_id}/access_tokens", %{}) do
      {:ok, %Tesla.Env{status: 201, body: response}} ->
        {:ok, response}

      _ ->
        {:error, :could_not_create_token}
    end
  end

  def get_istallations() do
    {:ok, token, _} = BeamBot.JWT.generate_token()

    client = get_client(token)
    get(client, "installation/repositories")
  end

  def get_pull_request(owner, repo, issue_number) do
    installation_id = get_installation_id()
    {:ok, token} = TokenManager.get_installation_token(installation_id)

    client = get_client(token)
    get(client, "repos/#{owner}/#{repo}/pulls/#{issue_number}")
  end

  def merge_branch(owner, repo, base_branch, branch_to_merge) do
    installation_id = get_installation_id()
    {:ok, token} = TokenManager.get_installation_token(installation_id)

    client = get_client(token)

    payload = %{
      base: base_branch,
      head: branch_to_merge,
      commit_message: "deploy merge"
    }

    post(client, "repos/#{owner}/#{repo}/merges", %{body: payload})
  end

  defp get_installation_id(), do: System.get_env("GITHUB_INSTALLATION_ID")

  defp get_client(token) do
    Tesla.client([
      {Tesla.Middleware.BaseUrl, "https://api.github.com/"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.BearerAuth, token: token},
      {Tesla.Middleware.Headers,
       [
         {"Accept", "application/vnd.github+json"},
         {"X-GitHub-Api-Version", "2022-11-28"},
         {"User-Agent", "BeamBot"}
       ]}
    ])
  end
end
