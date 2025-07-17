{:ok, _} = Application.ensure_all_started(:ex_machina)

# Mocks
Mox.defmock(BeamBot.Adapters.Providers.ProviderMock, for: BeamBot.Ports.Provider)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Beambot.Repo, :manual)
