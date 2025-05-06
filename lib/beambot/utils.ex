defmodule BeamBot.Utils do
  @moduledoc false
  def get_bot_name do
    System.get_env("BOT_NAME", "beambot")
  end

  def get_bot_prefix do
    "/#{get_bot_name()}"
  end
end
