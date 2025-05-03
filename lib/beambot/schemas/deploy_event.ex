defmodule BeamBot.Schemas.DeployEvent do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields ~w(status pr_number environment action user)a
  @optional_fields ~w(reason)a

  @valid_status ~w(deployed failed in_progress created deleted)

  @type t :: %__MODULE__{}

  @primary_key {:id, :id, autogenerate: true}
  @timestamps_opts [type: :utc_datetime_usec]
  schema "deploy_events" do
    field :status, :string
    field :pr_number, :integer
    field :environment, :string
    field :action, :string
    field :user, :string
    field :reason, :string

    timestamps()
  end

  @spec changeset(schema :: __MODULE__.t(), params :: map()) :: Ecto.Changeset.t()
  def changeset(schema \\ %__MODULE__{}, params) do
    schema
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:status, @valid_status)
  end
end
