alias ADB.Store
alias ADB.Srv

defmodule Srv do
  @vsn "0.1.0"
  @moduledoc """
  Az egyszalu adatbazis szerver-modulja.

  `@vsn "#{@vsn}"`
  """

  defmacro __using__([]) do
    quote location: :keep do
      use GenServer
      require Logger
      alias ADB.Store
      # @spec start_link(name) :: GenServer.on_start()
      # def start_link(), do: GenServer.start_link(__MODULE__, [name], name: name)

      @impl true
      # @spec init(List.t()) :: {:ok, Store.t()}
      @spec init(List.t()) :: {:ok, Store.t()} | {:stop, any}
      def init(args) do
        s = Store.constructor("#{__MODULE__}-#{inspect(self())}")

        case init_callback(s, args) do
          # Mindenkeppen vegigvisszuk, hogy bealljanak a szabalyok.
          {:ok, s} -> {:ok, Store.cycle(s)}
          # x -> x
        end
      end

      @spec handle_info(any, Store.t()) :: {:noreply, Store.t()}
      @impl true
      def handle_info(msg, s) do
        case msg do
          :timeout ->
            s = Store.cycle(s)
            if Store.checkout_advanced(s), do: {:noreply, s, 0}, else: {:noreply, s}

          _ ->
            {:noreply, handle_info_callback(s, msg), 0}
        end

        # def handle_info
      end

      @spec init_callback(Store.t(), any) :: {:ok, Store.t()} | {:stop, any}
      # def init_callback(s, _args) do
      #   {:ok, s}
      # end

      @spec handle_info_callback(Store.t(), any) :: Store.t()
      # def handle_info_callback(s, _msg) do
      #   s
      # end

      # defoverridable init_callback: 2, handle_info_callback: 2

      # quote
    end

    # defmacro __using__
  end

  # defmodule
end
