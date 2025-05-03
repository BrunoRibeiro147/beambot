defmodule BeamBot.Schemas.DeployLock do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields ~w(environment locked_by pr_number)a
  @optional_fields ~w(reason)a

  @type t :: %__MODULE__{}

  @primary_key {:id, :id, autogenerate: true}
  @timestamps_opts [type: :utc_datetime_usec]
  schema "deploy_locks" do
    field :pr_number, :integer
    field :environment, :string
    field :locked_by, :string
    field :reason, :string

    timestamps()
  end

  @spec changeset(schema :: __MODULE__.t(), params :: map()) :: Ecto.Changeset.t()
  def changeset(schema \\ %__MODULE__{}, params) do
    schema
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
