defmodule Util.TimexPatch do
  @vsn "0.1.0"
  @moduledoc """
  Ami a `Timex`-ben problemas.

  @vsn "#{@vsn}"
  """

  @doc """
  `:strftime` parse. `mask` is the mask.

  Return: `{ts, x}`
  - `ts`: a timestamp, vagy egy jo kozelites. Ha teljesen remenytelen, akkor a helyi idot adja vissza, de mindig ertelmes idot.
  - `x`: a hibauzenet, ha van.
  """
  @spec parse_timestamp(String.t(), String.t()) :: {Integer.t(), String.t() | nil}
  def parse_timestamp(timestamp, mask) do
    case Timex.parse(timestamp, mask, :strftime) do
      {:ok, x} ->
        y = x |> Timex.to_datetime(:local)

        case y do
          %stru{} when stru in [Timex.AmbiguousDateTime] -> {Timex.to_unix(y.after), "Timex.to_datetime(#{timestamp}, :local) ambiguous: #{inspect(y)}."}
          %stru{} when stru in [DateTime] -> {Timex.to_unix(y), nil}
          {:error, msg} -> {System.system_time(:second), "Timex.to_datetime(#{timestamp}, :local) error: #{inspect(msg)}."}
          msg -> {System.system_time(:second), "Timex.to_datetime(#{timestamp}, :local) unknown: #{inspect(msg)}."}
        end

      {:error, msg} ->
        {System.system_time(:second), "Timex.parse(#{timestamp}, ) error: #{inspect(msg)}."}
    end
  end
end
