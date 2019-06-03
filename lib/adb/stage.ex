alias ADB.Mlmap
alias ADB.Stage
alias ADB.Rule

defmodule Stage do
  @vsn "0.1.0"

  require Mlmap
  require Logger
  require Util
  Util.arrow_assignment()

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
            last_mod1: nil,
            last_mod2: nil,
            last_mod12: nil,
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
          stage1: Mlmap.t_diff(),
          stage2: Mlmap.t_diff(),
          stage12: Mlmap.t_diff(),
          diff1: Mlmap.t_diff(),
          diff2: Mlmap.t_diff(),
          diff12: Mlmap.t_diff(),
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
          last_mod1: %{String.t() => Integer.t()},
          last_mod2: %{String.t() => Integer.t()},
          last_mod12: %{{String.t(), String.t()} => Integer.t()},
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

  defmacro mconstructor(orig1, orig2, orig12, diff1, diff2, diff12, name, rule_ver, binding, last, internal1, internal2, internal12, last_mod1, last_mod2, last_mod12, real, pid, burst) do
    mod = __MODULE__

    quote do
      %unquote(mod){
        orig1: unquote(orig1),
        orig2: unquote(orig2),
        orig12: unquote(orig12),
        diff1: unquote(diff1),
        diff2: unquote(diff2),
        diff12: unquote(diff12),
        name: unquote(name),
        rule_ver: unquote(rule_ver),
        binding: unquote(binding),
        last: unquote(last),
        internal1: unquote(internal1),
        internal2: unquote(internal2),
        internal12: unquote(internal12),
        last_mod1: unquote(last_mod1),
        last_mod2: unquote(last_mod2),
        last_mod12: unquote(last_mod12),
        current1: unquote(internal1),
        current2: unquote(internal2),
        current12: unquote(internal12),
        real: unquote(real),
        keep: unquote(real),
        pid: unquote(pid),
        burst: unquote(burst)
      }
    end
  end

  @spec constructor(
          orig1 :: Mulmap.t(),
          orig2 :: Mulmap.t(),
          orig12 :: Mulmap.t(),
          diff1 :: Mulmap.t_diff(),
          diff2 :: Mulmap.t_diff(),
          diff12 :: Mulmap.t_diff(),
          name :: Mulmap.iden(),
          rule_ver :: Integer.t(),
          binding :: Rule.binding(),
          last :: Integer.t(),
          internal1 :: Mulmap.t(),
          internal2 :: Mulmap.t(),
          internal12 :: Mulmap.t(),
          last_mod1 :: %{String.t() => Integer.t()},
          last_mod2 :: %{String.t() => Integer.t()},
          last_mod12 :: %{{String.t(), String.t()} => Integer.t()},
          real :: Boolean.t(),
          pid :: String.t(),
          burst :: Rule.burst()
        ) :: t
  def constructor(orig1, orig2, orig12, diff1, diff2, diff12, name, rule_ver, binding, last, internal1, internal2, internal12, last_mod1, last_mod2, last_mod12, real, pid, burst) do
    mconstructor(orig1, orig2, orig12, diff1, diff2, diff12, name, rule_ver, binding, last, internal1, internal2, internal12, last_mod1, last_mod2, last_mod12, real, pid, burst)
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

    case Mlmap.supdate(s.internal1, lst, val) do
      :bump ->
        s

      :undefined ->
        %{s | internal1: %{}, stage1: :undefined, internal2: %{}, stage2: :undefined, internal12: %{}, stage12: :undefined}

      {internal1, lst} ->
        stage1 = Mlmap.dupdate(s.current1, s.stage1, lst, val)

        case lst do
          [map, key | rest] ->
            lst12 = [{map, key} | rest]
            # Itt ennek jonak kell lennie, nem lehet :undefined vagy :bump...
            {internal12, lst12} = Mlmap.supdate(s.internal12, lst12, val)
            stage12 = Mlmap.dupdate(s.current12, s.stage12, lst12, val)

            if iden != nil do
              lst2 = [key, map | rest]

              case Mlmap.supdate(s.internal2, lst2, val) do
                :bump ->
                  {s.internal2, s.stage2, internal12, stage12}

                :undefined ->
                  {%{}, :undefined, internal12, stage12}

                {internal2, lst2} ->
                  stage2 = Mlmap.dupdate(s.current12, s.stage2, lst2, val)
                  {internal2, stage2, internal12, stage12}
              end
            else
              {s.internal2, s.stage2, internal12, stage12}
            end

          _ ->
            {s.internal2, s.stage2, s.internal12, s.stage12}
        end >>> {internal2, stage2, internal12, stage12}

        %{s | internal1: internal1, stage1: stage1, internal2: internal2, stage2: stage2, internal12: internal12, stage12: stage12}
    end
  end

  @spec put(t, [{[any], any, iden}]) :: t
  def put(s, lstlst) do
    # orig -diff-> current -stage-> internal
    current1 = s.current1
    current2 = s.current2
    current12 = s.current12

    lstlst
    |> Enum.reduce(
      {s.internal1, s.stage1, s.internal2, s.stage2, s.internal12, s.stage12},
      fn {lst, val, iden}, {internal1, stage1, internal2, stage2, internal12, stage12} ->
        # Logger.warn("putl #{inspect({lst, val, iden})}")

        case Mlmap.supdate(internal1, lst, val) do
          :bump ->
            {internal1, stage1, internal2, stage2, internal12, stage12}

          :undefined ->
            {%{}, :undefined, %{}, :undefined, %{}, :undefined}

          {internal1, ulst} ->
            stage1 = Mlmap.dupdate(current1, stage1, ulst, val)

            case lst do
              [map, key | rest] ->
                lst12 = [{map, key} | rest]
                # Itt ennek jonak kell lennie, nem lehet :undefined vagy :bump...
                {internal12, lst12} = Mlmap.supdate(internal12, lst12, val)
                stage12 = Mlmap.dupdate(current12, stage12, lst12, val)

                if iden != nil do
                  lst2 = [key, map | rest]

                  case Mlmap.supdate(internal2, lst2, val) do
                    :bump ->
                      {internal1, stage1, internal2, stage2, internal12, stage12}

                    :undefined ->
                      {internal1, stage1, %{}, :undefined, internal12, stage12}

                    {internal2, lst2} ->
                      stage2 = Mlmap.dupdate(current2, stage2, lst2, val)
                      {internal1, stage1, internal2, stage2, internal12, stage12}
                  end
                else
                  {internal1, stage1, internal2, stage2, internal12, stage12}
                end

              _ ->
                {internal1, stage1, internal2, stage2, internal12, stage12}
            end
        end
      end
    ) >>> {internal1, stage1, internal2, stage2, internal12, stage12}

    %{s | internal1: internal1, stage1: stage1, internal2: internal2, stage2: stage2, internal12: internal12, stage12: stage12}
  end

  ######          ##     ## ######## ########   ######   ########          ######
  ##              ###   ### ##       ##     ## ##    ##  ##                    ##
  ##              #### #### ##       ##     ## ##        ##                    ##
  ##              ## ### ## ######   ########  ##   #### ######                ##
  ##              ##     ## ##       ##   ##   ##    ##  ##                    ##
  ##              ##     ## ##       ##    ##  ##    ##  ##                    ##
  ######          ##     ## ######## ##     ##  ######   ########          ######

  @doc """
  Egy diff-et olvaszt be. Kifejezetten diff-et.
  """
  @spec merge(t, [any], Map.t(), iden) :: t
  def merge(s, lst, val, iden) do
    # Logger.warn("mer #{inspect({lst, val, iden})}")

    {l1, l2} =
      case lst do
        [map, key | rest] ->
          {[], [{map, key, rest, val, iden}]}

        [map] ->
          Enum.reduce(val, {[], []}, fn {key, v}, {acc1, acc2} ->
            Mlmap.casemap v do
              {acc1, [{map, key, [], v, iden} | acc2]}
            else
              {[{[map, key], v, iden} | acc1], acc2}
            end
          end)

        _ ->
          Enum.reduce(val, {[], []}, fn {map, v2}, {acc1, acc2} ->
            Mlmap.casemap v2 do
              Enum.reduce(v2, {acc1, acc2}, fn {key, v}, {acc1x, acc2x} ->
                Mlmap.casemap(v, do: {acc1x, [{map, key, [], v, iden} | acc2x]}, else: {[{[map, key], v, iden} | acc1x], acc2x})
              end)
            else
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
    current1 = s.current1
    current2 = s.current2
    current12 = s.current12

    Enum.reduce(ops, {s.internal1, s.stage1, s.internal2, s.stage2, s.internal12, s.stage12}, fn {map, key, lst, val, iden}, {internal1, stage1, internal2, stage2, internal12, stage12} ->
      ulst = [map, key | lst]

      case Mlmap.smerdate(internal1, ulst, val) do
        :bump ->
          {internal1, stage1, internal2, stage2, internal12, stage12}

        {:undefined, _, _} ->
          {%{}, :undefined, %{}, :undefined, %{}, :undefined}

        {internal1, ulst, nval} ->
          nval = Util.wife(nval, nval == :bump, do: val)

          case nval do
            :undefined -> Mlmap.dupdate(current1, stage1, ulst, :undefined)
            _ -> Mlmap.dmerdate(current1, stage1, ulst, nval)
          end >>> stage1

          lst12 = [{map, key} | lst]

          case nval do
            :undefined ->
              {internal12, lst12} = Mlmap.supdate(internal12, lst12, :undefined)
              stage12 = Mlmap.dupdate(current12, stage12, lst12, :undefined)

              if iden != nil do
                lst2 = [key, map | lst]

                case Mlmap.supdate(internal2, lst2, :undefined) do
                  :bump ->
                    {internal1, stage1, internal2, stage2, internal12, stage12}

                  :undefined ->
                    {internal1, stage1, %{}, :undefined, internal12, stage12}

                  {internal2, lst2} ->
                    stage2 = Mlmap.dupdate(current2, stage2, lst2, :undefined)
                    {internal1, stage1, internal2, stage2, internal12, stage12}
                end
              else
                {internal1, stage1, internal2, stage2, internal12, stage12}
              end

            _ ->
              {internal12, lst12} = Mlmap.smerdate_n(internal12, lst12, nval)
              stage12 = Mlmap.dmerdate(current12, stage12, lst12, nval)

              if iden != nil do
                lst2 = [key, map | lst]

                case Mlmap.smerdate(internal2, lst2, nval) do
                  :bump ->
                    {internal1, stage1, internal2, stage2, internal12, stage12}

                  {:undefined, _, _} ->
                    {internal1, stage1, %{}, :undefined, internal12, stage12}

                  {internal2, lst2, nnval} ->
                    nnval = Util.wife(nnval, nnval == :bump, do: nval)

                    case nnval do
                      :undefined -> Mlmap.dupdate(current2, stage2, lst2, :undefined)
                      _ -> Mlmap.dmerdate(current2, stage2, lst2, nnval)
                    end >>> stage2

                    {internal1, stage1, internal2, stage2, internal12, stage12}
                end
              else
                {internal1, stage1, internal2, stage2, internal12, stage12}
              end
          end
      end
    end) >>> {internal1, stage1, internal2, stage2, internal12, stage12}

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
                Mlmap.casemap v do
                  {acc1, [{map, key, [], v, iden} | acc2]}
                else
                  {[{[map, key], v, iden} | acc1], acc2}
                end
              end)

            _ ->
              Enum.reduce(val, {l1, l2}, fn {map, v2}, {acc1, acc2} ->
                Mlmap.casemap v2 do
                  Enum.reduce(v2, {acc1, acc2}, fn {key, v}, {acc1x, acc2x} ->
                    Mlmap.casemap(v, do: {acc1x, [{map, key, [], v, iden} | acc2x]}, else: {[{[map, key], v, iden} | acc1x], acc2x})
                  end)
                else
                  {[{[map], v2, iden} | acc1], acc2}
                end
              end)
          end
      end
    end) >>> {l1, l2}

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
