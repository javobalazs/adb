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

  def merge(a, b), do: Map.merge(a, b, &resolver/3)

  @spec get(t, [any], any) :: any
  def get(s, lst, defa \\ :undefined) do
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
        upd =
          case Map.fetch(s, key) do
            {:ok, map} -> update(map, rest, val)
            :error -> make_from_lst(rest, val)
          end

        Map.put(s, key, upd)
    end
  end

  @spec merdate(t, [any], any) :: t
  def merdate(s, lst, val) do
    case lst do
      [] ->
        merge(s, val)

      [key | rest] ->
        upd =
          case Map.fetch(s, key) do
            {:ok, map} -> merdate(map, rest, val)
            :error -> make_from_lst(rest, val)
          end

        Map.put(s, key, upd)
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
        case Map.fetch(s, key) do
          {:ok, map} -> supdate_aux(map, rest, val)
          :error -> smake_from_lst(rest, val)
        end
        |> evaluate_upd(s, key)
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
        res = merge(s, val) |> filter()
        if res == %{} and (val != %{} or s != %{}), do: :undefined, else: res

      [key | rest] ->
        case Map.fetch(s, key) do
          {:ok, map} -> smerdate_aux(map, rest, val)
          :error -> smake_from_lst(rest, val)
        end
        |> evaluate_upd(s, key)
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

  @spec filter(t) :: t
  def filter(s) do
    s
    |> Enum.map(fn {k, v} ->
      case v do
        %{__struct__: _} ->
          {k, v}

        x when is_map(x) ->
          if Map.size(v) == 0 do
            {k, %{}}
          else
            v = filter(v)
            if v == %{}, do: :undefined, else: {k, v}
          end

        _ ->
          {k, v}
      end
    end)
    |> Enum.filter(fn x -> x != :undefined end)
    |> Map.new()
  end

  @spec filter(t, t) :: t
  def filter(s, s2) do
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
                    v = filter(v, v2)
                    if v == %{}, do: :undefined, else: {k, v}
                  end

                _ ->
                  {k, v}
              end

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

  @spec map(t, [any], (any -> any)) :: [any]
  def map(s, lst, fnc), do: get(s, lst, %{}) |> Enum.map(fnc) |> Enum.filter(fn x -> x != :bump end)

  @spec reduce(t, [any], a, (any, a -> a)) :: a when a: var
  def reduce(s, lst, acc, fnc), do: get(s, lst, %{}) |> Enum.reduce(acc, fnc)

  @spec reduce_while(t, [any], a, (any, a -> {:cont, a} | {:halt, a})) :: a when a: var
  def reduce_while(s, lst, acc, fnc), do: get(s, lst, %{}) |> Enum.reduce_while(acc, fnc)

  @type nondeleted :: :unchanged | :inserted | :changed
  @type event :: :deleted | nondeleted
  @type fullfun :: (key :: any, event :: event, old :: any, new :: any -> any | :bump)
  @type mapfun :: (key :: any, event :: nondeleted, old :: any, new :: any -> any | :bump)
  @type redfun(a) :: (key :: any, event :: event, old :: any, new :: any, acc :: a -> a)
  @type red_while_fun(a) :: (key :: any, event :: event, old :: any, new :: any, acc :: a -> {:cont, a} | {:halt, a})

  @spec full(t, t, t, [any], fullfun) :: [any]
  def full(orig, diff, last, lst, fnc) do
    orig = get(orig, lst, %{})
    diff = get(diff, lst, %{})
    last = get(last, lst, %{})

    case last do
      %{__struct__: _} ->
        []

      x when is_map(x) ->
        first =
          Enum.map(last, fn {k, v} ->
            {event, ori} =
              case Map.fetch(diff, k) do
                :error ->
                  {:same, v}

                {:ok, _df} ->
                  case Map.fetch(orig, k) do
                    :error -> {:inserted, :undefined}
                    {:ok, xori} -> {:changed, xori}
                  end
              end

            fnc.(k, event, ori, v)
          end)
          |> Enum.filter(fn v -> v != :bump end)

        second =
          diff
          |> Enum.filter(fn {_k, v} -> v == :undefined end)
          |> Enum.reduce([], fn {k, _}, acc ->
            ori = Map.get(orig, k)
            [fnc.(k, :deleted, ori, :undefined) | acc]
          end)
          |> Enum.filter(fn v -> v != :bump end)

        Enum.reverse(second, first)

      _ ->
        []
    end
  end

  @spec track(t, t, [any], mapfun) :: [any]
  def track(orig, diff, lst, fnc) do
    orig = get(orig, lst, %{})
    diff = get(diff, lst, %{})

    case diff do
      %{__struct__: _} ->
        []

      x when is_map(x) ->
        Enum.map(diff, fn {k, v} ->
          {event, ori} =
            case v do
              :undefined ->
                {:deleted, Map.get(orig, k)}

              _ ->
                case Map.fetch(orig, k) do
                  :error -> {:inserted, :undefined}
                  {:ok, xori} -> {:changed, xori}
                end
            end

          fnc.(k, event, ori, v)
        end)
        |> Enum.filter(fn v -> v != :bump end)

      _ ->
        []
    end
  end

  @spec track_reduce(t, t, [any], a, redfun(a)) :: a when a: var
  def track_reduce(orig, diff, lst, acc, fnc) do
    orig = get(orig, lst, %{})
    diff = get(diff, lst, %{})

    case diff do
      %{__struct__: _} ->
        acc

      x when is_map(x) ->
        Enum.reduce(diff, acc, fn {k, v}, acc ->
          {event, ori} =
            case v do
              :undefined ->
                {:deleted, Map.get(orig, k)}

              _ ->
                case Map.fetch(orig, k) do
                  :error -> {:inserted, :undefined}
                  {:ok, xori} -> {:changed, xori}
                end
            end

          fnc.(k, event, ori, v, acc)
        end)

      _ ->
        acc
    end
  end

  @spec track_reduce_while(t, t, [any], a, red_while_fun(a)) :: a when a: var
  def track_reduce_while(orig, diff, lst, acc, fnc) do
    orig = get(orig, lst, %{})
    diff = get(diff, lst, %{})

    case diff do
      %{__struct__: _} ->
        acc

      x when is_map(x) ->
        Enum.reduce_while(diff, acc, fn {k, v}, acc ->
          {event, ori} =
            case v do
              :undefined ->
                {:deleted, Map.get(orig, k)}

              _ ->
                case Map.fetch(orig, k) do
                  :error -> {:inserted, :undefined}
                  {:ok, xori} -> {:changed, xori}
                end
            end

          fnc.(k, event, ori, v, acc)
        end)

      _ ->
        acc
    end
  end

  # @spec reduce(t, [any], any, (key :: any, event :: event, old :: any, new :: any, acc :: a -> {:cont, a} | {:halt, a}) :: a when a: var
  # def reduce(s, lst, acc, fnc) do
  #   orig = getm(s, :orig1, lst, %{})
  #   diff = getm(s, :diff1, lst, %{})
  #   start = getm(s, :start1, lst, %{})
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

  # defmodule
end
