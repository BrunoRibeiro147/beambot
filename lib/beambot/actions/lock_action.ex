defmodule BeamBot.Actions.Lock do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :environment, :string
    field :reason, :string
  end

  def changeset(attrs) do
    environments = BeamBot.Environments.environments() |> Map.keys()

    %__MODULE__{}
    |> cast(attrs, [:environment, :reason])
    |> validate_required([:environment])
    |> validate_inclusion(:environment, environments)
  end
end
