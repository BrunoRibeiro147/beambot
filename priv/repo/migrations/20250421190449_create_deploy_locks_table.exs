defmodule Beambot.Repo.Migrations.CreateDeployLocksTable do
  use Ecto.Migration

  def change do
    create table(:deploy_locks) do
      add :environment, :string, null: false
      add :locked_by, :string
      add :pr_number, :integer
      add :reason, :string

      timestamps()
    end

    create unique_index(:deploy_locks, [:environment])
  end
end
