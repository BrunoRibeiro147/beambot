defmodule Beambot.Repo do
  use Ecto.Repo,
    otp_app: :beambot,
    adapter: Ecto.Adapters.Postgres
end
