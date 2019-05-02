alias ADB.Mlmap
alias ADB.Stage
alias ADB.Rule

defmodule Stage do
  @vsn "0.1.0"

  # require Logger

  @moduledoc """

  ```elixir
  merge(orig, diff) = start
  merge(start, stage) = internal
  ```


  `@vsn "#{@vsn}"`
  """

  ######          ######## ##    ## ########  ########          ######
  ##                 ##     ##  ##  ##     ## ##                    ##
  ##                 ##      ####   ##     ## ##                    ##
  ##                 ##       ##    ########  ######                ##
  ##                 ##       ##    ##        ##                    ##
  ##                 ##       ##    ##        ##                    ##
  ######             ##       ##    ##        ########          ######

  defstruct stage1: %{},
            stage2: %{},
            stage12: %{},
            diff1: nil,
            diff2: nil,
            diff12: nil,
            orig1: nil,
            orig2: nil,
            orig12: nil,
            current1: nil,
            current2: nil,
            current12: nil,
            name: nil,
            rule_ver: 0,
            binding: nil,
            last: 0,
            internal1: nil,
            internal2: nil,
            internal12: nil,
            real: true,
            keep: true,
            pid: nil,
            msgqueue: [],
            qlen: 0,
            burst: :cpu

  @typedoc """

  ```elixir
  merge(orig, diff) = start
  merge(start, stage) = internal
  ```

  """
  @type t :: %__MODULE__{
          stage1: Mlmap.t(),
          stage2: Mlmap.t(),
          stage12: Mlmap.t(),
          diff1: Mlmap.t(),
          diff2: Mlmap.t(),
          diff12: Mlmap.t(),
          orig1: Mlmap.t(),
          orig2: Mlmap.t(),
          orig12: Mlmap.t(),
          current1: Mlmap.t(),
          current2: Mlmap.t(),
          current12: Mlmap.t(),
          name: String.t(),
          rule_ver: Integer.t(),
          binding: Rule.binding(),
          last: Integer.t(),
          internal1: Mlmap.t(),
          internal2: Mlmap.t(),
          internal12: Mlmap.t(),
          real: Boolean.t(),
          keep: Boolean.t(),
          pid: String.t(),
          msgqueue: [{String.t(), any, any}],
          qlen: Integer.t(),
          burst: Rule.burst()
        }

  @type iden :: :iden | nil
  @type mapname ::
          :stage1
          | :stage2
          | :stage12
          | :diff1
          | :diff2
          | :diff12
          | :orig1
          | :orig2
          | :orig12
          | :current1
          | :current2
          | :current12
          | :internal1
          | :internal2
          | :internal12

  ######           ######   #######  ##    ##  ######  ######## ########  ##     ##  ######  ########  #######  ########           ######
  ##              ##    ## ##     ## ###   ## ##    ##    ##    ##     ## ##     ## ##    ##    ##    ##     ## ##     ##              ##
  ##              ##       ##     ## ####  ## ##          ##    ##     ## ##     ## ##          ##    ##     ## ##     ##              ##
  ##              ##       ##     ## ## ## ##  ######     ##    ########  ##     ## ##          ##    ##     ## ########               ##
  ##              ##       ##     ## ##  ####       ##    ##    ##   ##   ##     ## ##          ##    ##     ## ##   ##                ##
  ##              ##    ## ##     ## ##   ### ##    ##    ##    ##    ##  ##     ## ##    ##    ##    ##     ## ##    ##               ##
  ######           ######   #######  ##    ##  ######     ##    ##     ##  #######   ######     ##     #######  ##     ##          ######

  @spec constructor(
          orig1 :: Map.t(),
          orig2 :: Map.t(),
          orig12 :: Map.t(),
          diff1 :: Map.t(),
          diff2 :: Map.t(),
          diff12 :: Map.t(),
          name :: Mulmap.iden(),
          rule_ver :: Integer.t(),
          binding :: Rule.binding(),
          last :: Integer.t(),
          internal1 :: Map.t(),
          internal2 :: Map.t(),
          internal12 :: Map.t(),
          real :: Boolean.t(),
          pid :: String.t(),
          burst :: Rule.burst()
        ) :: t
  def constructor(orig1, orig2, orig12, diff1, diff2, diff12, name, rule_ver, binding, last, internal1, internal2, internal12, real, pid, burst) do
    %__MODULE__{
      orig1: orig1,
      orig2: orig2,
      orig12: orig12,
      diff1: diff1,
      diff2: diff2,
      diff12: diff12,
      name: name,
      rule_ver: rule_ver,
      binding: binding,
      last: last,
      internal1: internal1,
      internal2: internal2,
      internal12: internal12,
      current1: internal1,
      current2: internal2,
      current12: internal12,
      real: real,
      keep: real,
      pid: pid,
      burst: burst
    }
  end

  @spec get(t, [any], any) :: any
  def get(s, lst, defa \\ :undefined) do
    Mlmap.get(s.internal1, lst, defa)
  end

  @spec getm(t, mapname, [any], any) :: any
  def getm(s, map, lst, defa \\ :undefined) do
    mp = Map.get(s, map)
    Mlmap.get(mp, lst, defa)
  end

  @doc """
  Ha valodi szabaly fut, akkor felpattintsa-e a szabaly verzioszamat (`true`, default), vagy nem.
  """
  @spec set_keep(t, Boolean.t()) :: t
  def set_keep(s, keep), do: %{s | keep: keep}

  @doc """
  Ha imperativ output-muvelet soran hiba keletkezik a checkout-ban,
  azaz a mi szempontunkbol azonnali input, akkor itt kell jelezni.
  """
  @spec add_to_queue(t, [{String.t(), any, any}], any) :: t
  def add_to_queue(s, lst, val), do: %{s | msgqueue: [{lst, val, nil} | s.msgqueue], qlen: s.qlen + 1}

  ######          ########  ##     ## ########          ######
  ##              ##     ## ##     ##    ##                 ##
  ##              ##     ## ##     ##    ##                 ##
  ##              ########  ##     ##    ##                 ##
  ##              ##        ##     ##    ##                 ##
  ##              ##        ##     ##    ##                 ##
  ######          ##         #######     ##             ######

  @spec put(t, [any], any, iden) :: t
  def put(s, lst, val, iden \\ nil) do
    # orig -diff-> start -stage-> internal

    # Logger.warn("put  #{inspect({lst, val, iden})}")

    internal1 = Mlmap.supdate(s.internal1, lst, val)
    stage1 = Mlmap.update(s.stage1, lst, val)

    {internal2, stage2, internal12, stage12} =
      case lst do
        [map, key | rest] ->
          lst12 = [{map, key} | rest]
          internal12 = Mlmap.supdate(s.internal12, lst12, val)
          stage12 = Mlmap.update(s.stage12, lst12, val)

          if iden != nil do
            lst2 = [key, map | rest]
            internal2 = Mlmap.supdate(s.internal2, lst2, val)
            stage2 = Mlmap.update(s.stage2, lst2, val)
            {internal2, stage2, internal12, stage12}
          else
            {s.internal2, s.stage2, internal12, stage12}
          end

        _ ->
          {s.internal2, s.stage2, s.internal12, s.stage12}
      end

    %{s | internal1: internal1, stage1: stage1, internal2: internal2, stage2: stage2, internal12: internal12, stage12: stage12}
  end

  @spec put(t, [{[any], any, iden}]) :: t
  def put(s, lstlst) do
    # orig -diff-> start -stage-> internal

    {internal1, stage1, internal2, stage2, internal12, stage12} =
      lstlst
      |> Enum.reduce(
        {s.internal1, s.stage1, s.internal2, s.stage2, s.internal12, s.stage12},
        fn {lst, val, iden}, {internal1, stage1, internal2, stage2, internal12, stage12} ->
          # Logger.warn("putl #{inspect({lst, val, iden})}")

          internal1 = Mlmap.supdate(internal1, lst, val)
          stage1 = Mlmap.update(stage1, lst, val)

          case lst do
            [map, key | rest] ->
              lst12 = [{map, key} | rest]
              internal12 = Mlmap.supdate(internal12, lst12, val)
              stage12 = Mlmap.update(stage12, lst12, val)

              if iden != nil do
                lst2 = [key, map | rest]
                internal2 = Mlmap.supdate(internal2, lst2, val)
                stage2 = Mlmap.update(stage2, lst2, val)
                {internal1, stage1, internal2, stage2, internal12, stage12}
              else
                {internal1, stage1, internal2, stage2, internal12, stage12}
              end

            _ ->
              {internal1, stage1, internal2, stage2, internal12, stage12}
          end
        end
      )

    %{s | internal1: internal1, stage1: stage1, internal2: internal2, stage2: stage2, internal12: internal12, stage12: stage12}
  end

  ######          ##     ## ######## ########   ######   ########          ######
  ##              ###   ### ##       ##     ## ##    ##  ##                    ##
  ##              #### #### ##       ##     ## ##        ##                    ##
  ##              ## ### ## ######   ########  ##   #### ######                ##
  ##              ##     ## ##       ##   ##   ##    ##  ##                    ##
  ##              ##     ## ##       ##    ##  ##    ##  ##                    ##
  ######          ##     ## ######## ##     ##  ######   ########          ######

  @spec merge(t, [any], Map.t(), iden) :: t
  def merge(s, lst, val, iden) do
    # Logger.warn("mer #{inspect({lst, val, iden})}")

    {l1, l2} =
      case lst do
        [map, key | rest] ->
          {[], [{map, key, rest, val, iden}]}

        [map] ->
          Enum.reduce(val, {[], []}, fn {key, v}, {acc1, acc2} ->
            case v do
              %{__struct__: _} -> {[{[map, key], v, iden} | acc1], acc2}
              x when is_map(x) -> {acc1, [{map, key, [], v, iden} | acc2]}
              _ -> {[{[map, key], v, iden} | acc1], acc2}
            end
          end)

        _ ->
          Enum.reduce(val, {[], []}, fn {map, v2}, {acc1, acc2} ->
            case v2 do
              %{__struct__: _} ->
                {[{[map], v2, iden} | acc1], acc2}

              x when is_map(x) ->
                Enum.reduce(v2, {acc1, acc2}, fn {key, v}, {acc1x, acc2x} ->
                  case v do
                    %{__struct__: _} -> {[{[map, key], v, iden} | acc1x], acc2x}
                    x when is_map(x) -> {acc1x, [{map, key, [], v, iden} | acc2x]}
                    _ -> {[{[map, key], v, iden} | acc1x], acc2x}
                  end
                end)

              _ ->
                {[{[map], v2, iden} | acc1], acc2}
            end
          end)
      end

    s = put(s, l1)
    s = merge_2level(s, l2)
    s
  end

  @spec merge_2level(t, [{any, any, [any], Map.t(), iden}]) :: t
  def merge_2level(s, ops) do
    {internal1, stage1, internal2, stage2, internal12, stage12} =
      Enum.reduce(ops, {s.internal1, s.stage1, s.internal2, s.stage2, s.internal12, s.stage12}, fn {map, key, lst, val, iden}, {internal1, stage1, internal2, stage2, internal12, stage12} ->
        ulst = [map, key | lst]
        internal1 = Mlmap.smerdate(internal1, ulst, val)
        stage1 = Mlmap.merdate(stage1, ulst, val)

        lst12 = [{map, key} | lst]
        internal12 = Mlmap.smerdate(internal12, lst12, val)
        stage12 = Mlmap.merdate(stage12, lst12, val)

        if iden != nil do
          lst2 = [key, map | lst]
          internal2 = Mlmap.smerdate(internal2, lst2, val)
          stage2 = Mlmap.merdate(stage2, lst2, val)
          {internal1, stage1, internal2, stage2, internal12, stage12}
        else
          {internal1, stage1, internal2, stage2, internal12, stage12}
        end
      end)

    %{s | internal1: internal1, stage1: stage1, internal2: internal2, stage2: stage2, internal12: internal12, stage12: stage12}
  end

  ######           ######   #######  ##     ## ########  #### ##    ## ######## ########           ######
  ##              ##    ## ##     ## ###   ### ##     ##  ##  ###   ## ##       ##     ##              ##
  ##              ##       ##     ## #### #### ##     ##  ##  ####  ## ##       ##     ##              ##
  ##              ##       ##     ## ## ### ## ########   ##  ## ## ## ######   ##     ##              ##
  ##              ##       ##     ## ##     ## ##     ##  ##  ##  #### ##       ##     ##              ##
  ##              ##    ## ##     ## ##     ## ##     ##  ##  ##   ### ##       ##     ##              ##
  ######           ######   #######  ##     ## ########  #### ##    ## ######## ########           ######

  @spec bulk(t, [{:merge, [any], Map.t(), iden} | {[any], any, iden} | {any, any, [any], Map.t(), iden}]) :: t
  def bulk(s, lstlst) do
    # Logger.warn("mer #{inspect({lst, val, iden})}")

    {l1, l2} =
      lstlst
      |> Enum.reduce({[], []}, fn x, {l1, l2} ->
        case x do
          {_lst, _val, _iden} ->
            {[x | l1], l2}

          {_map, _key, _lst, _val, _iden} ->
            {l1, [x | l2]}

          {:merge, lst, val, iden} ->
            case lst do
              [map, key | rest] ->
                {l1, [{map, key, rest, val, iden} | l2]}

              [map] ->
                Enum.reduce(val, {l1, l2}, fn {key, v}, {acc1, acc2} ->
                  case v do
                    %{__struct__: _} -> {[{[map, key], v, iden} | acc1], acc2}
                    x when is_map(x) -> {acc1, [{map, key, [], v, iden} | acc2]}
                    _ -> {[{[map, key], v, iden} | acc1], acc2}
                  end
                end)

              _ ->
                Enum.reduce(val, {l1, l2}, fn {map, v2}, {acc1, acc2} ->
                  case v2 do
                    %{__struct__: _} ->
                      {[{[map], v2, iden} | acc1], acc2}

                    x when is_map(x) ->
                      Enum.reduce(v2, {acc1, acc2}, fn {key, v}, {acc1x, acc2x} ->
                        case v do
                          %{__struct__: _} -> {[{[map, key], v, iden} | acc1x], acc2x}
                          x when is_map(x) -> {acc1x, [{map, key, [], v, iden} | acc2x]}
                          _ -> {[{[map, key], v, iden} | acc1x], acc2x}
                        end
                      end)

                    _ ->
                      {[{[map], v2, iden} | acc1], acc2}
                  end
                end)
            end
        end
      end)

    s = put(s, l1)
    s = merge_2level(s, l2)
    s
  end

  ######          ##     ##    ###    ########        ## ########  ######## ########  ##     ##  ######  ########          ######
  ##              ###   ###   ## ##   ##     ##      ##  ##     ## ##       ##     ## ##     ## ##    ## ##                    ##
  ##              #### ####  ##   ##  ##     ##     ##   ##     ## ##       ##     ## ##     ## ##       ##                    ##
  ##              ## ### ## ##     ## ########     ##    ########  ######   ##     ## ##     ## ##       ######                ##
  ##              ##     ## ######### ##          ##     ##   ##   ##       ##     ## ##     ## ##       ##                    ##
  ##              ##     ## ##     ## ##         ##      ##    ##  ##       ##     ## ##     ## ##    ## ##                    ##
  ######          ##     ## ##     ## ##        ##       ##     ## ######## ########   #######   ######  ########          ######

  @spec mapm(t, mapname, [any], (any, any -> any)) :: [any]
  def mapm(s, mapname, lst, fnc), do: Map.get(s, mapname) |> Mlmap.map(lst, fnc)

  @spec map(t, [any], (any, any -> any)) :: [any]
  def map(s, lst, fnc), do: mapm(s, :internal1, lst, fnc)

  @spec reducem(t, mapname, [any], a, (any, any, a -> a)) :: a when a: var
  def reducem(s, mapname, lst, acc, fnc), do: Map.get(s, mapname) |> Mlmap.reduce(lst, acc, fnc)

  @spec reduce(t, [any], a, (any, any, a -> a)) :: a when a: var
  def reduce(s, lst, acc, fnc), do: reducem(s, :internal1, lst, acc, fnc)

  @spec reducem_while(t, mapname, [any], a, (any, any, a -> {:cont, a} | {:halt, a})) :: a when a: var
  def reducem_while(s, mapname, lst, acc, fnc), do: Map.get(s, mapname) |> Mlmap.reduce_while(lst, acc, fnc)

  @spec reduce_while(t, [any], a, (any, any, a -> {:cont, a} | {:halt, a})) :: a when a: var
  def reduce_while(s, lst, acc, fnc), do: reducem_while(s, :internal1, lst, acc, fnc)

  @spec full(t, [any], Mlmap.fulfun()) :: [any]
  def full(s, lst, fnc), do: Mlmap.full(s.orig1, s.diff1, s.current1, lst, fnc)

  @spec track(t, [any], Mlmap.mapfun()) :: [any]
  def track(s, lst, fnc), do: Mlmap.track(s.orig1, s.diff1, s.current1, lst, fnc)

  @spec track_reduce(t, [any], a, Mlmap.redfun(a)) :: a when a: var
  def track_reduce(s, lst, acc, fnc), do: Mlmap.track_reduce(s.orig1, s.diff1, s.current1, lst, acc, fnc)

  @spec track_reduce_while(t, [any], a, Mlmap.red_while_fun(a)) :: a when a: var
  def track_reduce_while(s, lst, acc, fnc), do: Mlmap.track_reduce_while(s.orig1, s.diff1, s.current1, lst, acc, fnc)

  @spec nfull(t, [any], Mlmap.fulfun()) :: [any]
  def nfull(s, lst, fnc), do: Mlmap.full(s.current1, s.stage1, s.internal1, lst, fnc)

  @spec ntrack(t, [any], Mlmap.mapfun()) :: [any]
  def ntrack(s, lst, fnc), do: Mlmap.track(s.current1, s.stage1, s.internal1, lst, fnc)

  @spec ntrack_reduce(t, [any], a, Mlmap.redfun(a)) :: a when a: var
  def ntrack_reduce(s, lst, acc, fnc), do: Mlmap.track_reduce(s.current1, s.stage1, s.internal1, lst, acc, fnc)

  @spec ntrack_reduce_while(t, [any], a, Mlmap.red_while_fun(a)) :: a when a: var
  def ntrack_reduce_while(s, lst, acc, fnc), do: Mlmap.track_reduce_while(s.current1, s.stage1, s.internal1, lst, acc, fnc)

  # @spec reduce(t, [any], any, (key :: any, event :: event, old :: any, new :: any, acc :: a -> {:cont, a} | {:halt, a}) :: a when a: var
  # def reduce(s, lst, acc, fnc) do
  #   orig = getm(s, :orig1, lst, %{})
  #   diff = getm(s, :diff1, lst, %{})
  #   start = getm(s, :current1, lst, %{})
  #
  #   case start do
  #     %{__struct__: _} ->
  #       acc
  #
  #     x when is_map(x) ->
  #       first =
  #         Enum.reduce_while(start, fn {k, v} ->
  #           {event, ori} =
  #             case Map.fetch(diff, k) do
  #               :error ->
  #                 {:same, v}
  #
  #               {:ok, _df} ->
  #                 case Map.fetch(orig, k) do
  #                   :error -> {:inserted, :undefined}
  #                   {:ok, xori} -> {:changed, xori}
  #                 end
  #             end
  #
  #           fnc.(k, event, ori, v)
  #         end)
  #         |> Enum.filter(fn v -> v != :skip end)
  #         |> Enum.map(fn {_, v} -> v end)
  #
  #       second =
  #         diff
  #         |> Enum.filter(fn {_k, v} -> v == :undefined end)
  #         |> Enum.reduce([], fn {k, _}, acc ->
  #           ori = Map.get(orig, k)
  #           [fnc.(k, :deleted, ori, :undefined) | acc]
  #         end)
  #         |> Enum.filter(fn v -> v != :skip end)
  #         |> Enum.map(fn {_, v} -> v end)
  #
  #       Enum.reverse(second, first)
  #
  #     _ ->
  #       acc
  #   end
  # end

  ######          ##     ##    ###    ########   #######        ## ########  ######## ########  ##     ##  ######  ########  #######           ######
  ##              ###   ###   ## ##   ##     ## ##     ##      ##  ##     ## ##       ##     ## ##     ## ##    ## ##       ##     ##              ##
  ##              #### ####  ##   ##  ##     ##        ##     ##   ##     ## ##       ##     ## ##     ## ##       ##              ##              ##
  ##              ## ### ## ##     ## ########   #######     ##    ########  ######   ##     ## ##     ## ##       ######    #######               ##
  ##              ##     ## ######### ##        ##          ##     ##   ##   ##       ##     ## ##     ## ##       ##       ##                     ##
  ##              ##     ## ##     ## ##        ##         ##      ##    ##  ##       ##     ## ##     ## ##    ## ##       ##                     ##
  ######          ##     ## ##     ## ##        ######### ##       ##     ## ######## ########   #######   ######  ######## #########          ######

  @spec mapm2(t, mapname, [any], (any, any, any -> any)) :: [any]
  def mapm2(s, mapname, lst, fnc), do: Map.get(s, mapname) |> Mlmap.map2(lst, fnc)

  @spec map2(t, [any], (any, any, any -> any)) :: [any]
  def map2(s, lst, fnc), do: mapm2(s, :internal1, lst, fnc)

  @spec reducem2(t, mapname, [any], a, (any, any, any, a -> a)) :: a when a: var
  def reducem2(s, mapname, lst, acc, fnc), do: Map.get(s, mapname) |> Mlmap.reduce2(lst, acc, fnc)

  @spec reduce2(t, [any], a, (any, any, any, a -> a)) :: a when a: var
  def reduce2(s, lst, acc, fnc), do: reducem2(s, :internal1, lst, acc, fnc)

  @spec reducem_while2(t, mapname, [any], a, (any, any, any, a -> {:cont, a} | {:halt, a})) :: a when a: var
  def reducem_while2(s, mapname, lst, acc, fnc), do: Map.get(s, mapname) |> Mlmap.reduce_while2(lst, acc, fnc)

  @spec reduce_while2(t, [any], a, (any, any, any, a -> {:cont, a} | {:halt, a})) :: a when a: var
  def reduce_while2(s, lst, acc, fnc), do: reducem_while2(s, :internal1, lst, acc, fnc)

  @spec track2(t, [any], Mlmap.mapfun2()) :: [any]
  def track2(s, lst, fnc), do: Mlmap.track2(s.orig1, s.diff1, s.current1, lst, fnc)

  @spec track_reduce2(t, [any], a, Mlmap.redfun2(a)) :: a when a: var
  def track_reduce2(s, lst, acc, fnc), do: Mlmap.track_reduce2(s.orig1, s.diff1, s.current1, lst, acc, fnc)

  @spec track_reduce_while2(t, [any], a, Mlmap.red_while_fun2(a)) :: a when a: var
  def track_reduce_while2(s, lst, acc, fnc), do: Mlmap.track_reduce_while2(s.orig1, s.diff1, s.current1, lst, acc, fnc)

  @spec ntrack2(t, [any], Mlmap.mapfun2()) :: [any]
  def ntrack2(s, lst, fnc), do: Mlmap.track2(s.current1, s.stage1, s.internal1, lst, fnc)

  @spec ntrack_reduce2(t, [any], a, Mlmap.redfun2(a)) :: a when a: var
  def ntrack_reduce2(s, lst, acc, fnc), do: Mlmap.track_reduce2(s.current1, s.stage1, s.internal1, lst, acc, fnc)

  @spec ntrack_reduce_while2(t, [any], a, Mlmap.red_while_fun2(a)) :: a when a: var
  def ntrack_reduce_while2(s, lst, acc, fnc), do: Mlmap.track_reduce_while2(s.current1, s.stage1, s.internal1, lst, acc, fnc)

  ######          ##     ##    ###    ########   #######        ## ########  ######## ########  ##     ##  ######  ########  #######           ######
  ##              ###   ###   ## ##   ##     ## ##     ##      ##  ##     ## ##       ##     ## ##     ## ##    ## ##       ##     ##              ##
  ##              #### ####  ##   ##  ##     ##        ##     ##   ##     ## ##       ##     ## ##     ## ##       ##              ##              ##
  ##              ## ### ## ##     ## ########   #######     ##    ########  ######   ##     ## ##     ## ##       ######    #######               ##
  ##              ##     ## ######### ##               ##   ##     ##   ##   ##       ##     ## ##     ## ##       ##              ##              ##
  ##              ##     ## ##     ## ##        ##     ##  ##      ##    ##  ##       ##     ## ##     ## ##    ## ##       ##     ##              ##
  ######          ##     ## ##     ## ##         #######  ##       ##     ## ######## ########   #######   ######  ########  #######           ######

  @spec mapm3(t, mapname, [any], (any, any, any, any -> any)) :: [any]
  def mapm3(s, mapname, lst, fnc), do: Map.get(s, mapname) |> Mlmap.map3(lst, fnc)

  @spec map3(t, [any], (any, any, any, any -> any)) :: [any]
  def map3(s, lst, fnc), do: mapm3(s, :internal1, lst, fnc)

  @spec reducem3(t, mapname, [any], a, (any, any, any, any, a -> a)) :: a when a: var
  def reducem3(s, mapname, lst, acc, fnc), do: Map.get(s, mapname) |> Mlmap.reduce3(lst, acc, fnc)

  @spec reduce3(t, [any], a, (any, any, any, any, a -> a)) :: a when a: var
  def reduce3(s, lst, acc, fnc), do: reducem3(s, :internal1, lst, acc, fnc)

  @spec reducem_while3(t, mapname, [any], a, (any, any, any, any, a -> {:cont, a} | {:halt, a})) :: a when a: var
  def reducem_while3(s, mapname, lst, acc, fnc), do: Map.get(s, mapname) |> Mlmap.reduce_while3(lst, acc, fnc)

  @spec reduce_while3(t, [any], a, (any, any, any, any, a -> {:cont, a} | {:halt, a})) :: a when a: var
  def reduce_while3(s, lst, acc, fnc), do: reducem_while3(s, :internal1, lst, acc, fnc)

  @spec track3(t, [any], Mlmap.mapfun3()) :: [any]
  def track3(s, lst, fnc), do: Mlmap.track3(s.orig1, s.diff1, s.current1, lst, fnc)

  @spec track_reduce3(t, [any], a, Mlmap.redfun3(a)) :: a when a: var
  def track_reduce3(s, lst, acc, fnc), do: Mlmap.track_reduce3(s.orig1, s.diff1, s.current1, lst, acc, fnc)

  @spec track_reduce_while3(t, [any], a, Mlmap.red_while_fun3(a)) :: a when a: var
  def track_reduce_while3(s, lst, acc, fnc), do: Mlmap.track_reduce_while3(s.orig1, s.diff1, s.current1, lst, acc, fnc)

  @spec ntrack3(t, [any], Mlmap.mapfun3()) :: [any]
  def ntrack3(s, lst, fnc), do: Mlmap.track3(s.current1, s.stage1, s.internal1, lst, fnc)

  @spec ntrack_reduce3(t, [any], a, Mlmap.redfun3(a)) :: a when a: var
  def ntrack_reduce3(s, lst, acc, fnc), do: Mlmap.track_reduce3(s.current1, s.stage1, s.internal1, lst, acc, fnc)

  @spec ntrack_reduce_while3(t, [any], a, Mlmap.red_while_fun3(a)) :: a when a: var
  def ntrack_reduce_while3(s, lst, acc, fnc), do: Mlmap.track_reduce_while3(s.current1, s.stage1, s.internal1, lst, acc, fnc)

  ######          ##     ##    ###    ########  ##              ## ########  ######## ########  ##     ##  ######  ######## ##                 ######
  ##              ###   ###   ## ##   ##     ## ##    ##       ##  ##     ## ##       ##     ## ##     ## ##    ## ##       ##    ##               ##
  ##              #### ####  ##   ##  ##     ## ##    ##      ##   ##     ## ##       ##     ## ##     ## ##       ##       ##    ##               ##
  ##              ## ### ## ##     ## ########  ##    ##     ##    ########  ######   ##     ## ##     ## ##       ######   ##    ##               ##
  ##              ##     ## ######### ##        #########   ##     ##   ##   ##       ##     ## ##     ## ##       ##       #########              ##
  ##              ##     ## ##     ## ##              ##   ##      ##    ##  ##       ##     ## ##     ## ##    ## ##             ##               ##
  ######          ##     ## ##     ## ##              ##  ##       ##     ## ######## ########   #######   ######  ########       ##           ######

  @spec mapm4(t, mapname, [any], (any, any, any, any, any -> any)) :: [any]
  def mapm4(s, mapname, lst, fnc), do: Map.get(s, mapname) |> Mlmap.map4(lst, fnc)

  @spec map4(t, [any], (any, any, any, any, any -> any)) :: [any]
  def map4(s, lst, fnc), do: mapm4(s, :internal1, lst, fnc)

  @spec reducem4(t, mapname, [any], a, (any, any, any, any, any, a -> a)) :: a when a: var
  def reducem4(s, mapname, lst, acc, fnc), do: Map.get(s, mapname) |> Mlmap.reduce4(lst, acc, fnc)

  @spec reduce4(t, [any], a, (any, any, any, any, any, a -> a)) :: a when a: var
  def reduce4(s, lst, acc, fnc), do: reducem4(s, :internal1, lst, acc, fnc)

  @spec reducem_while4(t, mapname, [any], a, (any, any, any, any, any, a -> {:cont, a} | {:halt, a})) :: a when a: var
  def reducem_while4(s, mapname, lst, acc, fnc), do: Map.get(s, mapname) |> Mlmap.reduce_while4(lst, acc, fnc)

  @spec reduce_while4(t, [any], a, (any, any, any, any, any, a -> {:cont, a} | {:halt, a})) :: a when a: var
  def reduce_while4(s, lst, acc, fnc), do: reducem_while4(s, :internal1, lst, acc, fnc)

  @spec track4(t, [any], Mlmap.mapfun4()) :: [any]
  def track4(s, lst, fnc), do: Mlmap.track4(s.orig1, s.diff1, s.current1, lst, fnc)

  @spec track_reduce4(t, [any], a, Mlmap.redfun4(a)) :: a when a: var
  def track_reduce4(s, lst, acc, fnc), do: Mlmap.track_reduce4(s.orig1, s.diff1, s.current1, lst, acc, fnc)

  @spec track_reduce_while4(t, [any], a, Mlmap.red_while_fun4(a)) :: a when a: var
  def track_reduce_while4(s, lst, acc, fnc), do: Mlmap.track_reduce_while4(s.orig1, s.diff1, s.current1, lst, acc, fnc)

  @spec ntrack4(t, [any], Mlmap.mapfun4()) :: [any]
  def ntrack4(s, lst, fnc), do: Mlmap.track4(s.current1, s.stage1, s.internal1, lst, fnc)

  @spec ntrack_reduce4(t, [any], a, Mlmap.redfun4(a)) :: a when a: var
  def ntrack_reduce4(s, lst, acc, fnc), do: Mlmap.track_reduce4(s.current1, s.stage1, s.internal1, lst, acc, fnc)

  @spec ntrack_reduce_while4(t, [any], a, Mlmap.red_while_fun4(a)) :: a when a: var
  def ntrack_reduce_while4(s, lst, acc, fnc), do: Mlmap.track_reduce_while4(s.current1, s.stage1, s.internal1, lst, acc, fnc)

  # defmodule
end
