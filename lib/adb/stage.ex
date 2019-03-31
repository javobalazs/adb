alias ADB.Mlmap
alias ADB.Stage
alias ADB.Rule

defmodule Stage do
  @vsn "0.1.0"
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
            start1: nil,
            start2: nil,
            start12: nil,
            name: nil,
            rule_ver: 0,
            binding: nil,
            last: 0,
            internal1: nil,
            internal2: nil,
            internal12: nil,
            pid: nil

  @typedoc """

  ```elixir
  merge(orig, diff) = start
  merge(start, stage) = internal
  ```

  """
  @type t :: %__MODULE__{
          stage1: Map.t(),
          stage2: Map.t(),
          stage12: Map.t(),
          diff1: Map.t(),
          diff2: Map.t(),
          diff12: Map.t(),
          orig1: Map.t(),
          orig2: Map.t(),
          orig12: Map.t(),
          start1: Map.t(),
          start2: Map.t(),
          start12: Map.t(),
          name: String.t(),
          rule_ver: Integer.t(),
          binding: Rule.binding(),
          last: Integer.t(),
          internal1: Map.t(),
          internal2: Map.t(),
          internal12: Map.t(),
          pid: String.t()
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
          | :start1
          | :start2
          | :start12
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
          pid :: String.t()
        ) :: t
  def constructor(orig1, orig2, orig12, diff1, diff2, diff12, name, rule_ver, binding, last, internal1, internal2, internal12, pid) do
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
      start1: internal1,
      start2: internal2,
      start12: internal12,
      pid: pid
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

  @spec put(t, [any], any, iden) :: t
  def put(s, lst, val, iden \\ nil) do
    # orig -diff-> start -stage-> internal

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

  @spec merge(t, [any], Map.t(), iden) :: t
  def merge(s, lst, val, iden) do
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
    s = merge_aux(s, l2)
    s
  end

  @spec merge_aux(t, [{any, any, [any], Map.t(), iden}]) :: t
  def merge_aux(s, ops) do
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

  # defmodule
end
