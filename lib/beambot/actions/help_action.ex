defmodule BeamBot.Actions.Help do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :message, :string
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:message])
    |> validate_required([:message])
  end
end
