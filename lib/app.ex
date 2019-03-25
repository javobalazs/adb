defmodule App do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Util.LogRotator.child_spec(:error_log),
      %{
        id: 6,
        start: {R24Core, :start_link, [:tdb]}
      }
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: ADB.Supervisor)
  end
end
