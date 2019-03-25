defmodule Util.LogRotator do
  @vsn "0.1.0"
  use GenServer
  require Logger
  @msg :log_rotate
  @shift 10
  @min_diff 1000

  @moduledoc """
  A napi logokat intezi a `:loggger_file_backend`-hez.

  `app.ex`:
  ```elixir
  defmodule App do
    use Application

    def start(_type, _args) do
      import Supervisor.Spec, warn: false

      children = [
        Util.LogRotator.child_spec(:error_log)
      ]

      Supervisor.start_link(children, strategy: :one_for_one, name: :supervisor)
    end
  end

  ```

  `config.exs`:
  ```elixir
  use Mix.Config

  config :logger,
    backends: [{LoggerFileBackend, :error_log}, :console]

  # configuration for the {LoggerFileBackend, :error_log} backend
  config :logger, :error_log,
    path: "log/inst.log",
    format: "$date $time $metadata[$level] $levelpad$message\n",
    metadata: [:line],
    level: :info

  # level: :error

  config :logger, :console,
    format: "$date $time $metadata[$level] $levelpad$message\n",
    metadata: [:line]
  ```

  @vsn "#{@vsn}"
  """

  defstruct logname: nil, date: nil, name: nil

  @typedoc """
  - `logname`: annak a lognak a neve, amit varialni akar.
  - `date`: az aktualis log datuma.
  """
  @type t :: %__MODULE__{
          logname: atom,
          date: Date.t(),
          name: String.t() | nil
        }

  @spec start_link(atom) :: GenServer.on_start()
  def start_link(logname) do
    GenServer.start_link(__MODULE__, [logname])
  end

  @spec speci(atom) :: Supervisor.child_spec()
  def speci(logname) do
    %{
      id: logname,
      start: {__MODULE__, :start_link, [logname]}
    }
  end

  @impl true
  @spec init(List.t()) :: {:ok, t}
  def init([logname]) do
    date = Timex.local() |> Timex.shift(days: -3) |> Timex.to_date()
    s = %__MODULE__{logname: logname, date: date}
    s = rotate(s)
    {:ok, s}
  end

  @spec rotate(t) :: t
  def rotate(s) do
    logname = s.logname
    datetime = Timex.local()
    date = datetime |> Timex.to_date()

    s =
      if date != s.date do
        oldname = s.name
        kl = Application.get_env(:logger, logname)
        path = Keyword.get(kl, :path, "file#{logname}")
        oldname = if oldname == nil, do: path, else: oldname
        path = path |> String.replace(~r/-\d\d\d\d-\d\d-\d\d-/, "") |> String.replace(~r/\.[^.]*$/, "")
        {:ok, frm} = Timex.format(date, "%Y-%m-%d", :strftime)
        path = "#{path}-#{frm}-.log"
        kl = Keyword.put(kl, :path, path)
        Logger.configure_backend({LoggerFileBackend, logname}, kl)
        Logger.warn("| LOG_ROTATOR | rotate | #{date} | new | #{path} | old | #{oldname} |")
        %{s | date: date, name: path}
      else
        Logger.warn("| LOG_ROTATOR | still | #{date} |")
        s
      end

    # Reschedule
    d2 = datetime |> Timex.shift(days: 1) |> Timex.beginning_of_day() |> Timex.shift(milliseconds: @shift)
    diff = Timex.diff(d2, datetime, :milliseconds)
    diff = if diff < @min_diff, do: @min_diff, else: diff
    Logger.warn("| LOG_ROTATOR | next_rotate | #{d2} |")
    Process.send_after(self(), @msg, diff)
    s
  end

  @impl true
  def handle_info(msg, s) do
    s =
      case msg do
        @msg -> rotate(s)
        _ -> s
      end

    {:noreply, s}
  end
end
