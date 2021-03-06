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
            # VAN ateses, ha a `:checkout`-ban olyan imperativ muvelet van, ami azonnal visszaad valamit,
            # ES modosulas van.
            if Store.checkout_fallthrough(s), do: {:noreply, s, 0}, else: {:noreply, s}
            # {:noreply, s}

          _ ->
            {:noreply, Store.add_to_queue(s, msg), 0}
        end

        # def handle_info
      end

      @spec init_callback(Store.t(), any) :: {:ok, Store.t()} | {:stop, any}
      # def init_callback(s, _args) do
      #   {:ok, s}
      # end

      # defoverridable init_callback: 2

      # quote
    end

    # defmacro __using__
  end

  # defmodule
end
