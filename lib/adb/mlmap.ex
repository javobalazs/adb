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

  # defmodule
end
