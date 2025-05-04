defmodule BeamBot.Environments do
  @moduledoc """
  This module store the supported environments
  """

  def environments do
    %{
      "office" => "us-east-1-office_deploy",
      "cubex" => "us-east-1-int-cubex_deploy"
    }
  end
end
