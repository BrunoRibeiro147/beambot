defmodule Beambot.Repo.Migrations.CreateDeployEventsTable do
  use Ecto.Migration

  def change do
    create table(:deploy_events) do
      add :status, :string
      add :pr_number, :integer
      add :environment, :string
      add :action, :string
      add :user, :string
      add :reason, :string

      timestamps()
    end
  end
end
