defmodule Util.TimexPatch do
  @vsn "0.1.1"
  @moduledoc """
  Ami a `Timex`-ben problemas.

  @vsn "#{@vsn}"
  """

  @doc """
  `:strftime` parse. `mask` is the mask.

  Return: `{ts, at, x}`
  - `ts`: a timestamp, vagy egy jo kozelites. Ha teljesen remenytelen, akkor a helyi idot adja vissza, de mindig ertelmes idot.
  - `at`: ha `:ok`, akkor valamilyen ertelemben jo ertek megy vissza, kulonben valami (rossz) tipp.
  - `x`: a hibauzenet, ha van.
  """
  @spec parse_timestamp(String.t(), String.t()) :: {Integer.t(), :ok | :error, String.t() | nil}
  def parse_timestamp(timestamp, mask) do
    case Timex.parse(timestamp, mask, :strftime) do
      {:ok, x} ->
        y = x |> Timex.to_datetime(:local)

        case y do
          %stru{} when stru in [Timex.AmbiguousDateTime] -> {Timex.to_unix(y.after), :ok, "Timex.to_datetime(#{timestamp}, :local) ambiguous: #{inspect(y)}."}
          %stru{} when stru in [DateTime] -> {Timex.to_unix(y), :ok, nil}
          {:error, msg} -> {System.system_time(:second), :error, "Timex.to_datetime(#{timestamp}, :local) error: #{inspect(msg)}."}
          msg -> {System.system_time(:second), :error, "Timex.to_datetime(#{timestamp}, :local) unknown: #{inspect(msg)}."}
        end

      {:error, msg} ->
        {System.system_time(:second), :error, "Timex.parse(#{timestamp}, #{mask}, :strftime) error: #{inspect(msg)}."}
    end
  end
end
