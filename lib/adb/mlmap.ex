alias ADB.Mlmap

defmodule Mlmap do
  @vsn "0.1.0"

  @type t :: Map.t()

  ######          ##     ## ######## ########   ######   ########               ######   ######## ########          ######
  ##              ###   ### ##       ##     ## ##    ##  ##            ##      ##    ##  ##          ##                 ##
  ##              #### #### ##       ##     ## ##        ##            ##      ##        ##          ##                 ##
  ##              ## ### ## ######   ########  ##   #### ######      ######    ##   #### ######      ##                 ##
  ##              ##     ## ##       ##   ##   ##    ##  ##            ##      ##    ##  ##          ##                 ##
  ##              ##     ## ##       ##    ##  ##    ##  ##            ##      ##    ##  ##          ##                 ##
  ######          ##     ## ######## ##     ##  ######   ########               ######   ########    ##             ######

  def resolver(_k, _v1, v2 = %{__struct__: _}), do: v2

  def resolver(_k, v1, v2) when is_map(v1) and is_map(v2), do: Map.merge(v1, v2, &resolver/3)

  def resolver(_k, _v1, v2), do: v2

  @spec merge(t, t) :: t
  def merge(a, b), do: Map.merge(a, b, &resolver/3)

  @spec get(t | :undefined, [any], any) :: any
  def get(s, lst, defa \\ :undefined) do
    case s do
      :undefined ->
        defa

      _ ->
        case lst do
          [] ->
            s

          [key | rest] ->
            case Map.fetch(s, key) do
              {:ok, val} -> get(val, rest, defa)
              :error -> defa
            end
        end
    end
  end

  @spec fetch(t | :undefined, [any]) :: {:ok, any} | :error
  def fetch(s, lst) do
    case s do
      :undefined ->
        :error

      _ ->
        case lst do
          [] ->
            {:ok, s}

          [key | rest] ->
            case Map.fetch(s, key) do
              {:ok, val} -> fetch(val, rest)
              :error -> :error
            end
        end
    end
  end

  ######          ##     ## ########  ########     ###    ######## ########          ######
  ##              ##     ## ##     ## ##     ##   ## ##      ##    ##                    ##
  ##              ##     ## ##     ## ##     ##  ##   ##     ##    ##                    ##
  ##              ##     ## ########  ##     ## ##     ##    ##    ######                ##
  ##              ##     ## ##        ##     ## #########    ##    ##                    ##
  ##              ##     ## ##        ##     ## ##     ##    ##    ##                    ##
  ######           #######  ##        ########  ##     ##    ##    ########          ######

  @spec update(t, [any], any) :: t
  def update(s, lst, val) do
    case lst do
      [] ->
        val

      [key | rest] ->
        case s do
          %{__struct__: _} ->
            upd = make_from_lst(rest, val)
            %{key => upd}

          x when is_map(x) ->
            upd =
              case Map.fetch(s, key) do
                {:ok, map} -> update(map, rest, val)
                :error -> make_from_lst(rest, val)
              end

            Map.put(s, key, upd)

          _ ->
            upd = make_from_lst(rest, val)
            %{key => upd}
        end
    end
  end

  @spec merdate(t, [any], any) :: t
  def merdate(s, lst, val) do
    case lst do
      [] ->
        merge(s, val)

      [key | rest] ->
        case s do
          %{__struct__: _} ->
            upd = make_from_lst(rest, val)
            %{key => upd}

          x when is_map(x) ->
            upd =
              case Map.fetch(s, key) do
                {:ok, map} -> merdate(map, rest, val)
                :error -> make_from_lst(rest, val)
              end

            Map.put(s, key, upd)

          _ ->
            upd = make_from_lst(rest, val)
            %{key => upd}
        end
    end
  end

  @spec make_from_lst([], a) :: a when a: var
  @spec make_from_lst(nonempty_list(any()), any) :: t
  def make_from_lst(lst, val) do
    case lst do
      [] -> val
      [k | rest] -> %{k => make_from_lst(rest, val)}
    end
  end

  ######          ########  ######## ##               ##     ## ########  ########     ###    ######## ########          ######
  ##              ##     ## ##       ##               ##     ## ##     ## ##     ##   ## ##      ##    ##                    ##
  ##              ##     ## ##       ##               ##     ## ##     ## ##     ##  ##   ##     ##    ##                    ##
  ##              ##     ## ######   ##       ####### ##     ## ########  ##     ## ##     ##    ##    ######                ##
  ##              ##     ## ##       ##               ##     ## ##        ##     ## #########    ##    ##                    ##
  ##              ##     ## ##       ##               ##     ## ##        ##     ## ##     ##    ##    ##                    ##
  ######          ########  ######## ########          #######  ##        ########  ##     ##    ##    ########          ######

  @spec supdate(t, [any], any) :: t
  def supdate(s, lst, val) do
    case supdate_aux(s, lst, val) do
      :undefined -> %{}
      res -> res
    end
  end

  @spec supdate_aux(t, [any], any) :: t
  def supdate_aux(s, lst, val) do
    case lst do
      [] ->
        val

      [key | rest] ->
        case s do
          %{__struct__: _} ->
            smake_from_lst(rest, val) |> evaluate_upd(%{}, key)

          x when is_map(x) ->
            case Map.fetch(s, key) do
              {:ok, map} -> supdate_aux(map, rest, val)
              :error -> smake_from_lst(rest, val)
            end
            |> evaluate_upd(s, key)

          _ ->
            smake_from_lst(rest, val) |> evaluate_upd(%{}, key)
        end
    end
  end

  @spec smerdate(t, [any], any) :: t
  def smerdate(s, lst, val) do
    case smerdate_aux(s, lst, val) do
      :undefined -> %{}
      res -> res
    end
  end

  @spec smerdate_aux(t, [any], any) :: t | :undefined
  def smerdate_aux(s, lst, val) do
    case lst do
      [] ->
        res = merge(s, val) |> normalize()
        if res == %{} and (val != %{} or s != %{}), do: :undefined, else: res

      [key | rest] ->
        case s do
          %{__struct__: _} ->
            smake_from_lst(rest, val) |> evaluate_upd(%{}, key)

          x when is_map(x) ->
            case Map.fetch(s, key) do
              {:ok, map} -> smerdate_aux(map, rest, val)
              :error -> smake_from_lst(rest, val)
            end
            |> evaluate_upd(s, key)

          _ ->
            smake_from_lst(rest, val) |> evaluate_upd(%{}, key)
        end
    end
  end

  @spec evaluate_upd(any, t, any) :: t | :undefined
  def evaluate_upd(upd, s, key) do
    case upd do
      :undefined ->
        s2 = Map.delete(s, key)
        if s != %{} and s2 == %{}, do: :undefined, else: s2

      _ ->
        Map.put(s, key, upd)
    end
  end

  @spec smake_from_lst([], a) :: a when a: var
  @spec smake_from_lst(nonempty_list(any()), any) :: t | :undefined
  def smake_from_lst(lst, val) do
    case lst do
      [] ->
        val

      [k | rest] ->
        upd = smake_from_lst(rest, val)
        if upd == :undefined, do: :undefined, else: %{k => upd}
    end
  end

  ######          ######## #### ##       ######## ######## ########           ######
  ##              ##        ##  ##          ##    ##       ##     ##              ##
  ##              ##        ##  ##          ##    ##       ##     ##              ##
  ##              ######    ##  ##          ##    ######   ########               ##
  ##              ##        ##  ##          ##    ##       ##   ##                ##
  ##              ##        ##  ##          ##    ##       ##    ##               ##
  ######          ##       #### ########    ##    ######## ##     ##          ######

  @doc """
  Egy diff alkalmazasa utani allapot, kiszuri a felesleges dolgokat.
  """
  @spec normalize(t) :: t
  def normalize(s) do
    s
    |> Enum.map(fn {k, v} ->
      case v do
        %{__struct__: _} ->
          {k, v}

        x when is_map(x) ->
          if Map.size(v) == 0 do
            {k, %{}}
          else
            v = normalize(v)
            if v == %{}, do: :undefined, else: {k, v}
          end

        :undefined ->
          :undefined

        _ ->
          {k, v}
      end
    end)
    |> Enum.filter(fn x -> x != :undefined end)
    |> Map.new()
  end

  @doc """
  Egy diff-et optimalizal.
  """
  @spec filter(t, t, any) :: t
  def filter(s, s2, meta \\ :undefined) do
    s
    |> Enum.map(fn {k, v} ->
      case Map.fetch(s2, k) do
        {:ok, v2} ->
          case v do
            %{__struct__: _} ->
              if v == v2, do: :undefined, else: {k, v}

            x when is_map(x) ->
              case v2 do
                %{__struct__: _} ->
                  {k, v}

                y when is_map(y) ->
                  if Map.size(v) == 0 do
                    {k, %{}}
                  else
                    v = filter(v, v2, meta)
                    if v == %{}, do: :undefined, else: {k, v}
                  end

                _ ->
                  {k, v}
              end

            :undefined ->
              if meta == v2, do: :undefined, else: {k, meta}

            _ ->
              if v == v2, do: :undefined, else: {k, v}
          end

        :error ->
          case v do
            :undefined -> :undefined
            _ -> {k, v}
          end
      end
    end)
    |> Enum.filter(fn x -> x != :undefined end)
    |> Map.new()
  end

  ######          ##     ##    ###    ########        ## ########  ######## ########  ##     ##  ######  ########          ######
  ##              ###   ###   ## ##   ##     ##      ##  ##     ## ##       ##     ## ##     ## ##    ## ##                    ##
  ##              #### ####  ##   ##  ##     ##     ##   ##     ## ##       ##     ## ##     ## ##       ##                    ##
  ##              ## ### ## ##     ## ########     ##    ########  ######   ##     ## ##     ## ##       ######                ##
  ##              ##     ## ######### ##          ##     ##   ##   ##       ##     ## ##     ## ##       ##                    ##
  ##              ##     ## ##     ## ##         ##      ##    ##  ##       ##     ## ##     ## ##    ## ##                    ##
  ######          ##     ## ##     ## ##        ##       ##     ## ######## ########   #######   ######  ########          ######

  @doc """
  A kimenete szurt flatlist.
  """
  @spec map(t | :undefined, [any], (any, any -> any)) :: [any]
  def map(s, lst, fnc) do
    case get(s, lst) do
      %{__struct__: _} -> []
      mp when is_map(mp) -> mp |> Enum.map(fn {k, v} -> fnc.(k, v) end) |> List.flatten() |> Enum.filter(fn x -> x != :bump end)
      _ -> []
    end
  end

  @spec reduce(t | :undefined, [any], a, (any, any, a -> a)) :: a when a: var
  def reduce(s, lst, acc, fnc) do
    case get(s, lst) do
      %{__struct__: _} -> acc
      mp when is_map(mp) -> mp |> Enum.reduce(acc, fn {k, v}, acc -> fnc.(k, v, acc) end)
      _ -> acc
    end
  end

  @spec reduce_while(t | :undefined, [any], a, (any, any, a -> {:cont, a} | {:halt, a})) :: a when a: var
  def reduce_while(s, lst, acc, fnc) do
    case get(s, lst) do
      %{__struct__: _} -> acc
      mp when is_map(mp) -> mp |> Enum.reduce_while(acc, fn {k, v}, acc -> fnc.(k, v, acc) end)
      _ -> acc
    end
  end

  @type nonunchanged :: :deleted | :inserted | :changed
  @type event :: :unchanged | nonunchanged
  @type fullfun :: (key :: any, event :: event, old :: any, diff :: any, new :: any -> any | :bump)
  @type mapfun :: (key :: any, event :: nonunchanged, old :: any, diff :: any, new :: any -> any | :bump)
  @type redfun(a) :: (key :: any, event :: nonunchanged, old :: any, diff :: any, new :: any, acc :: a -> a)
  @type red_while_fun(a) :: (key :: any, event :: nonunchanged, old :: any, diff :: any, new :: any, acc :: a -> {:cont, a} | {:halt, a})

  @spec full(t | :undefined, t | :undefined, t | :undefined, [any], fullfun) :: [any]
  def full(orig, diff, curr, lst, fnc) do
    orig = get(orig, lst)
    diff = get(diff, lst)
    curr = get(curr, lst)

    case curr do
      %{__struct__: _} ->
        []

      x when is_map(x) ->
        first =
          Enum.map(curr, fn {k, v} ->
            {event, ori, dif} =
              case Map.fetch(diff, k) do
                :error ->
                  {:unchanged, v, v}

                {:ok, dif} ->
                  case Map.fetch(orig, k) do
                    :error -> {:inserted, :undefined, dif}
                    {:ok, xori} -> {:changed, xori, dif}
                  end
              end

            fnc.(k, event, ori, dif, v)
          end)
          |> Enum.filter(fn v -> v != :bump end)

        second =
          diff
          |> Enum.filter(fn {_k, v} -> v == :undefined end)
          |> Enum.reduce([], fn {k, _}, acc ->
            ori = Map.get(orig, k)
            [fnc.(k, :deleted, ori, :undefined, :undefined) | acc]
          end)
          |> Enum.filter(fn v -> v != :bump end)

        Enum.reverse(second, first)

      _ ->
        []
    end
  end

  @spec track(t | :undefined, t | :undefined, t | :undefined, [any], mapfun) :: [any]
  def track(orig, diff, curr, lst, fnc) do

    orig = get(orig, lst)
    curr = get(curr, lst)

    map(diff, lst, fn k, v ->
      {event, ori, cur} =
        case v do
          :undefined ->
            {:deleted, Map.get(orig, k), :undefined}

          _ ->
            case fetch(orig, [k]) do
              :error -> {:inserted, :undefined, v}
              {:ok, xori} -> {:changed, xori, Map.get(curr, k)}
            end
        end

      fnc.(k, event, ori, v, cur)
    end)
  end

  @spec track_reduce(t | :undefined, t | :undefined, t | :undefined, [any], a, redfun(a)) :: a when a: var
  def track_reduce(orig, diff, curr, lst, acc, fnc) do
    orig = get(orig, lst)
    curr = get(curr, lst)

    reduce(diff, lst, acc, fn k, v, acc ->
      {event, ori, cur} =
        case v do
          :undefined ->
            {:deleted, Map.get(orig, k), :undefined}

          _ ->
            case fetch(orig, [k]) do
              :error -> {:inserted, :undefined, v}
              {:ok, xori} -> {:changed, xori, Map.get(curr, k)}
            end
        end

      fnc.(k, event, ori, v, cur, acc)
    end)
  end

  @spec track_reduce_while(t | :undefined, t | :undefined, t | :undefined, [any], a, red_while_fun(a)) :: a when a: var
  def track_reduce_while(orig, diff, curr, lst, acc, fnc) do
    orig = get(orig, lst)
    curr = get(curr, lst)

    reduce_while(diff, lst, acc, fn k, v, acc ->
      {event, ori, cur} =
        case v do
          :undefined ->
            {:deleted, Map.get(orig, k), :undefined}

          _ ->
            case fetch(orig, [k]) do
              :error -> {:inserted, :undefined, v}
              {:ok, xori} -> {:changed, xori, Map.get(curr, k)}
            end
        end

      fnc.(k, event, ori, v, cur, acc)
    end)
  end

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

  @spec map2(t | :undefined, [any], (any, any, any -> any)) :: [any]
  def map2(s, lst, fnc) do
    map(s, lst, fn k, v ->
      case v do
        %{__struct__: _} -> :bump
        x when is_map(x) -> v |> Enum.map(fn {vk, vv} -> fnc.(k, vk, vv) end)
        _ -> :bump
      end
    end)
  end

  @spec reduce2(t | :undefined, [any], a, (any, any, any, a -> a)) :: a when a: var
  def reduce2(s, lst, acc, fnc) do
    reduce(s, lst, acc, fn k, v, acc ->
      case v do
        %{__struct__: _} -> acc
        x when is_map(x) -> v |> Enum.reduce(acc, fn {vk, vv}, acc -> fnc.(k, vk, vv, acc) end)
        _ -> acc
      end
    end)
  end

  @spec reduce_while2(t | :undefined, [any], a, (any, any, any, a -> {:cont, a} | {:halt, a})) :: a when a: var
  def reduce_while2(s, lst, acc, fnc) do
    reduce_while(s, lst, acc, fn k, v, acc ->
      case v do
        %{__struct__: _} -> acc
        x when is_map(x) -> v |> Enum.reduce_while(acc, fn {vk, vv}, acc -> fnc.(k, vk, vv, acc) end)
        _ -> acc
      end
    end)
  end

  @type mapfun2 :: (key1 :: any, key2 :: any, event :: nonunchanged, old :: any, diff :: any, new :: any -> any | :bump)
  @type redfun2(a) :: (key1 :: any, key2 :: any, event :: nonunchanged, old :: any, diff :: any, new :: any, acc :: a -> a)
  @type red_while_fun2(a) :: (key1 :: any, key2 :: any, event :: nonunchanged, old :: any, diff :: any, new :: any, acc :: a -> {:cont, a} | {:halt, a})

  @spec track2(t | :undefined, t | :undefined, t | :undefined, [any], mapfun2) :: [any]
  def track2(orig, diff, curr, lst, fnc) do
    orig = get(orig, lst)
    curr = get(curr, lst)

    map2(diff, lst, fn k1, k2, v ->
      {event, ori, cur} =
        case v do
          :undefined ->
            {:deleted, get(orig, [k1, k2]), :undefined}

          _ ->
            case fetch(orig, [k1, k2]) do
              :error -> {:inserted, :undefined, v}
              {:ok, xori} -> {:changed, xori, get(curr, [k1, k2])}
            end
        end

      fnc.(k1, k2, event, ori, v, cur)
    end)
  end

  @spec track_reduce2(t | :undefined, t | :undefined, t | :undefined, [any], a, redfun2(a)) :: a when a: var
  def track_reduce2(orig, diff, curr, lst, acc, fnc) do
    orig = get(orig, lst)
    curr = get(curr, lst)

    reduce2(diff, lst, acc, fn k1, k2, v, acc ->
      {event, ori, cur} =
        case v do
          :undefined ->
            {:deleted, get(orig, [k1, k2]), :undefined}

          _ ->
            case fetch(orig, [k1, k2]) do
              :error -> {:inserted, :undefined, v}
              {:ok, xori} -> {:changed, xori, get(curr, [k1, k2])}
            end
        end

      fnc.(k1, k2, event, ori, v, cur, acc)
    end)
  end

  @spec track_reduce_while2(t | :undefined, t | :undefined, t | :undefined, [any], a, red_while_fun2(a)) :: a when a: var
  def track_reduce_while2(orig, diff, curr, lst, acc, fnc) do
    orig = get(orig, lst)
    curr = get(curr, lst)

    reduce_while2(diff, lst, acc, fn k1, k2, v, acc ->
      {event, ori, cur} =
        case v do
          :undefined ->
            {:deleted, get(orig, [k1, k2]), :undefined}

          _ ->
            case fetch(orig, [k1, k2]) do
              :error -> {:inserted, :undefined, v}
              {:ok, xori} -> {:changed, xori, get(curr, [k1, k2])}
            end
        end

      fnc.(k1, k2, event, ori, v, cur, acc)
    end)
  end

  ######          ##     ##    ###    ########   #######        ## ########  ######## ########  ##     ##  ######  ########  #######           ######
  ##              ###   ###   ## ##   ##     ## ##     ##      ##  ##     ## ##       ##     ## ##     ## ##    ## ##       ##     ##              ##
  ##              #### ####  ##   ##  ##     ##        ##     ##   ##     ## ##       ##     ## ##     ## ##       ##              ##              ##
  ##              ## ### ## ##     ## ########   #######     ##    ########  ######   ##     ## ##     ## ##       ######    #######               ##
  ##              ##     ## ######### ##               ##   ##     ##   ##   ##       ##     ## ##     ## ##       ##              ##              ##
  ##              ##     ## ##     ## ##        ##     ##  ##      ##    ##  ##       ##     ## ##     ## ##    ## ##       ##     ##              ##
  ######          ##     ## ##     ## ##         #######  ##       ##     ## ######## ########   #######   ######  ########  #######           ######

  @spec map3(t | :undefined, [any], (any, any, any, any -> any)) :: [any]
  def map3(s, lst, fnc) do
    map2(s, lst, fn k1, k2, v ->
      case v do
        %{__struct__: _} -> :bump
        x when is_map(x) -> v |> Enum.map(fn {vk, vv} -> fnc.(k1, k2, vk, vv) end)
        _ -> :bump
      end
    end)
  end

  @spec reduce3(t | :undefined, [any], a, (any, any, any, any, a -> a)) :: a when a: var
  def reduce3(s, lst, acc, fnc) do
    reduce2(s, lst, acc, fn k1, k2, v, acc ->
      case v do
        %{__struct__: _} -> acc
        x when is_map(x) -> v |> Enum.reduce(acc, fn {vk, vv}, acc -> fnc.(k1, k2, vk, vv, acc) end)
        _ -> acc
      end
    end)
  end

  @spec reduce_while3(t | :undefined, [any], a, (any, any, any, any, a -> {:cont, a} | {:halt, a})) :: a when a: var
  def reduce_while3(s, lst, acc, fnc) do
    reduce_while2(s, lst, acc, fn k1, k2, v, acc ->
      case v do
        %{__struct__: _} -> acc
        x when is_map(x) -> v |> Enum.reduce_while(acc, fn {vk, vv}, acc -> fnc.(k1, k2, vk, vv, acc) end)
        _ -> acc
      end
    end)
  end

  @type mapfun3 :: (key1 :: any, key2 :: any, key3 :: any, event :: nonunchanged, old :: any, diff :: any, new :: any -> any | :bump)
  @type redfun3(a) :: (key1 :: any, key2 :: any, key3 :: any, event :: nonunchanged, old :: any, diff :: any, new :: any, acc :: a -> a)
  @type red_while_fun3(a) :: (key1 :: any, key2 :: any, key3 :: any, event :: nonunchanged, old :: any, diff :: any, new :: any, acc :: a -> {:cont, a} | {:halt, a})

  @spec track3(t | :undefined, t | :undefined, t | :undefined, [any], mapfun3) :: [any]
  def track3(orig, diff, curr, lst, fnc) do
    orig = get(orig, lst)
    curr = get(curr, lst)

    map3(diff, lst, fn k1, k2, k3, v ->
      {event, ori, cur} =
        case v do
          :undefined ->
            {:deleted, get(orig, [k1, k2, k3]), :undefined}

          _ ->
            case fetch(orig, [k1, k2, k3]) do
              :error -> {:inserted, :undefined, v}
              {:ok, xori} -> {:changed, xori, get(curr, [k1, k2, k3])}
            end
        end

      fnc.(k1, k2, k3, event, ori, v, cur)
    end)
  end

  @spec track_reduce3(t | :undefined, t | :undefined, t | :undefined, [any], a, redfun3(a)) :: a when a: var
  def track_reduce3(orig, diff, curr, lst, acc, fnc) do
    orig = get(orig, lst)
    curr = get(curr, lst)

    reduce3(diff, lst, acc, fn k1, k2, k3, v, acc ->
      {event, ori, cur} =
        case v do
          :undefined ->
            {:deleted, get(orig, [k1, k2, k3]), :undefined}

          _ ->
            case fetch(orig, [k1, k2, k3]) do
              :error -> {:inserted, :undefined, v}
              {:ok, xori} -> {:changed, xori, get(curr, [k1, k2, k3])}
            end
        end

      fnc.(k1, k2, k3, event, ori, v, cur, acc)
    end)
  end

  @spec track_reduce_while3(t | :undefined, t | :undefined, t | :undefined, [any], a, red_while_fun3(a)) :: a when a: var
  def track_reduce_while3(orig, diff, curr, lst, acc, fnc) do
    orig = get(orig, lst)
    curr = get(curr, lst)

    reduce_while3(diff, lst, acc, fn k1, k2, k3, v, acc ->
      {event, ori, cur} =
        case v do
          :undefined ->
            {:deleted, get(orig, [k1, k2, k3]), :undefined}

          _ ->
            case fetch(orig, [k1, k2, k3]) do
              :error -> {:inserted, :undefined, v}
              {:ok, xori} -> {:changed, xori, get(curr, [k1, k2, k3])}
            end
        end

      fnc.(k1, k2, k3, event, ori, v, cur, acc)
    end)
  end

  ######          ##     ##    ###    ########  ##              ## ########  ######## ########  ##     ##  ######  ######## ##                 ######
  ##              ###   ###   ## ##   ##     ## ##    ##       ##  ##     ## ##       ##     ## ##     ## ##    ## ##       ##    ##               ##
  ##              #### ####  ##   ##  ##     ## ##    ##      ##   ##     ## ##       ##     ## ##     ## ##       ##       ##    ##               ##
  ##              ## ### ## ##     ## ########  ##    ##     ##    ########  ######   ##     ## ##     ## ##       ######   ##    ##               ##
  ##              ##     ## ######### ##        #########   ##     ##   ##   ##       ##     ## ##     ## ##       ##       #########              ##
  ##              ##     ## ##     ## ##              ##   ##      ##    ##  ##       ##     ## ##     ## ##    ## ##             ##               ##
  ######          ##     ## ##     ## ##              ##  ##       ##     ## ######## ########   #######   ######  ########       ##           ######

  @spec map4(t | :undefined, [any], (any, any, any, any, any -> any)) :: [any]
  def map4(s, lst, fnc) do
    map3(s, lst, fn k1, k2, k3, v ->
      case v do
        %{__struct__: _} -> :bump
        x when is_map(x) -> v |> Enum.map(fn {vk, vv} -> fnc.(k1, k2, k3, vk, vv) end)
        _ -> :bump
      end
    end)
  end

  @spec reduce4(t | :undefined, [any], a, (any, any, any, any, any, a -> a)) :: a when a: var
  def reduce4(s, lst, acc, fnc) do
    reduce3(s, lst, acc, fn k1, k2, k3, v, acc ->
      case v do
        %{__struct__: _} -> acc
        x when is_map(x) -> v |> Enum.reduce(acc, fn {vk, vv}, acc -> fnc.(k1, k2, k3, vk, vv, acc) end)
        _ -> acc
      end
    end)
  end

  @spec reduce_while4(t | :undefined, [any], a, (any, any, any, any, any, a -> {:cont, a} | {:halt, a})) :: a when a: var
  def reduce_while4(s, lst, acc, fnc) do
    reduce_while3(s, lst, acc, fn k1, k2, k3, v, acc ->
      case v do
        %{__struct__: _} -> acc
        x when is_map(x) -> v |> Enum.reduce_while(acc, fn {vk, vv}, acc -> fnc.(k1, k2, k3, vk, vv, acc) end)
        _ -> acc
      end
    end)
  end

  @type mapfun4 :: (key1 :: any, key2 :: any, key3 :: any, key4 :: any, event :: nonunchanged, old :: any, diff :: any, new :: any -> any | :bump)
  @type redfun4(a) :: (key1 :: any, key2 :: any, key3 :: any, key4 :: any, event :: nonunchanged, old :: any, diff :: any, new :: any, acc :: a -> a)
  @type red_while_fun4(a) :: (key1 :: any, key2 :: any, key3 :: any, key4 :: any, event :: nonunchanged, old :: any, diff :: any, new :: any, acc :: a -> {:cont, a} | {:halt, a})

  @spec track4(t | :undefined, t | :undefined, t | :undefined, [any], mapfun4) :: [any]
  def track4(orig, diff, curr, lst, fnc) do
    orig = get(orig, lst)
    curr = get(curr, lst)

    map4(diff, lst, fn k1, k2, k3, k4, v ->
      {event, ori, cur} =
        case v do
          :undefined ->
            {:deleted, get(orig, [k1, k2, k3, k4]), :undefined}

          _ ->
            case fetch(orig, [k1, k2, k3, k4]) do
              :error -> {:inserted, :undefined, v}
              {:ok, xori} -> {:changed, xori, get(curr, [k1, k2, k3, k4])}
            end
        end

      fnc.(k1, k2, k3, k4, event, ori, v, cur)
    end)
  end

  @spec track_reduce4(t | :undefined, t | :undefined, t | :undefined, [any], a, redfun4(a)) :: a when a: var
  def track_reduce4(orig, diff, curr, lst, acc, fnc) do
    orig = get(orig, lst)
    curr = get(curr, lst)

    reduce4(diff, lst, acc, fn k1, k2, k3, k4, v, acc ->
      {event, ori, cur} =
        case v do
          :undefined ->
            {:deleted, get(orig, [k1, k2, k3, k4]), :undefined}

          _ ->
            case fetch(orig, [k1, k2, k3, k4]) do
              :error -> {:inserted, :undefined, v}
              {:ok, xori} -> {:changed, xori, get(curr, [k1, k2, k3, k4])}
            end
        end

      fnc.(k1, k2, k3, k4, event, ori, v, cur, acc)
    end)
  end

  @spec track_reduce_while4(t | :undefined, t | :undefined, t | :undefined, [any], a, red_while_fun4(a)) :: a when a: var
  def track_reduce_while4(orig, diff, curr, lst, acc, fnc) do
    orig = get(orig, lst)
    curr = get(curr, lst)

    reduce_while4(diff, lst, acc, fn k1, k2, k3, k4, v, acc ->
      {event, ori, cur} =
        case v do
          :undefined ->
            {:deleted, get(orig, [k1, k2, k3, k4]), :undefined}

          _ ->
            case fetch(orig, [k1, k2, k3, k4]) do
              :error -> {:inserted, :undefined, v}
              {:ok, xori} -> {:changed, xori, get(curr, [k1, k2, k3, k4])}
            end
        end

      fnc.(k1, k2, k3, k4, event, ori, v, cur, acc)
    end)
  end

  # defmodule
end
