defmodule BeamBot.Utils do
  def get_bot_name() do
    System.get_env("BOT_NAME")
  end

  def get_bot_prefix() do
    "/#{get_bot_name()}"
  end
end
