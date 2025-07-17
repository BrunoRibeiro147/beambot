defmodule Beambot.Adapters.Jira do
  require Logger
  import Tesla

  def create_release() do
    client = get_client()

    body = %{
      archived: false,
      description: "An excellent version",
      name: "office/#{DateTime.utc_now() |> DateTime.to_date() |> Date.to_string()}",
      projectId: 10000,
      releaseDate: DateTime.utc_now() |> DateTime.to_date() |> Date.to_string(),
      released: false
    }

    case post(client, "/version", body) do
      {:ok, %Tesla.Env{status: 201, body: response}} ->
        {:ok, response}

      {:ok, %Tesla.Env{status: status, body: body}} ->
        Logger.error(%{status: status, body: body})
        {:error, "Error when sending the user message"}

      {:error, error} ->
        Logger.error(%{error: error})
        {:error, "Error when sending the user message"}
    end
  end

  def update_issue() do
    client = get_client()

    case post(client, "/version") do
      {:ok, %Tesla.Env{status: 201, body: response}} ->
        {:ok, response}

      {:ok, %Tesla.Env{status: status, body: body}} ->
        Logger.error(%{status: status, body: body})
        {:error, "Error when sending the user message"}

      {:error, error} ->
        Logger.error(%{error: error})
        {:error, "Error when sending the user message"}
    end
  end

  def get_project_info() do
    client = get_client()

    case get(client, "/project/OFF") do
      {:ok, %Tesla.Env{status: 200, body: response}} ->
        {:ok, response}

      {:ok, %Tesla.Env{status: status, body: body}} ->
        Logger.error(%{status: status, body: body})
        {:error, "Error when sending the user message"}

      {:error, error} ->
        Logger.error(%{error: error})
        {:error, "Error when sending the user message"}
    end
  end

  @spec get_issue() :: {:error, <<_::280>>} | {:ok, any()}
  def get_issue() do
    client = get_client()

    case get(client, "/issue/OFF-5") do
      {:ok, %Tesla.Env{status: 200, body: response}} ->
        {:ok, response}

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
      {Tesla.Middleware.BaseUrl, "https://hilllynndev.atlassian.net/rest/api/3"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.BasicAuth,
       Map.merge(
         %{
           username: "hilllynn.dev@gmail.com",
           password:
             "ATATT3xFfGF05hTbNA0cM9O2r9uYNpXU7IxlD_duBcCThcFkjdou_Cb-p7ogKYjaIP44G8HM0Ypl2uKDNsw1nXnHAaQHWKJpkDiBaN4d12Ua8EFiacM-RoGNClhcdnXevMgq53YDbCVqZcW0oOAf9elS2bBVwxevL8hmNj5Tav2dhwRG5a7qLh0=0233171D"
         },
         %{}
       )}
    ])
  end
end
