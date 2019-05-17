alias ADB.Mlmap

defmodule Mlmap do
  @vsn "0.4.0"
  @moduledoc """
  Tobbszintu map-ek kezelese.

  @vsn `"#{@vsn}"`
  """

  @type t :: Map.t()

  # require Logger

  ######          ##     ## ######## #### ##       #### ######## ##    ##          ######
  ##              ##     ##    ##     ##  ##        ##     ##     ##  ##               ##
  ##              ##     ##    ##     ##  ##        ##     ##      ####                ##
  ##              ##     ##    ##     ##  ##        ##     ##       ##                 ##
  ##              ##     ##    ##     ##  ##        ##     ##       ##                 ##
  ##              ##     ##    ##     ##  ##        ##     ##       ##                 ##
  ######           #######     ##    #### ######## ####    ##       ##             ######

  @doc """
  Ha `expr` (egy valtozo) egy map (de nem struct), akkor `clause`, kulonben `other`.
  ```elixir
  x = casemap v, do: Map.get(v, key, nil), else: nil
  ```
  """
  defmacro casemap(expr, do: clause, else: other) do
    quote do
      case unquote(expr) do
        %{__struct__: _} -> unquote(other)
        y when is_map(y) -> unquote(clause)
        _ -> unquote(other)
      end
    end
  end

  @doc """
  Ha `expr` egy map (de nem struct), akkor `clause`, kulonben `other`, es `xvar` fogja tartalmazni `expr` erteket.
  Ez akkor hasznos, ha `expr` egy tenyleges kifejezes.
  ```elixir
  x = casemap Map.get(valami, kulcs, nil), mp, do: Map.get(mp, key, nil), else: nil
  ```
  """
  defmacro casemap(expr, xvar, do: clause, else: other) do
    quote do
      case unquote(expr) do
        %{__struct__: _} -> unquote(other)
        unquote(xvar) when is_map(unquote(xvar)) -> unquote(clause)
        _ -> unquote(other)
      end
    end
  end

  @doc """
  Ha `expr` (egy valtozo) egy map (de nem struct), akkor `clause`, kulonben `other`.
  Olvashatosagot javit, ha `other` valami trivialis es rovid.
  ```elixir
  x = casemapx v, nil, do: Map.get(v, key, nil)
  ```
  """
  defmacro casemapx(expr, other, do: clause) do
    quote do
      case unquote(expr) do
        %{__struct__: _} -> unquote(other)
        y when is_map(y) -> unquote(clause)
        _ -> unquote(other)
      end
    end
  end

  @doc """
  Ha `expr` egy map (de nem struct), akkor `clause`, kulonben `other`, es `xvar` fogja tartalmazni `expr` erteket.
  Ez akkor hasznos, ha `expr` egy tenyleges kifejezes.
  Olvashatosagot javit, ha `other` valami trivialis es rovid.
  ```elixir
  x = casemapx Map.get(valami, kulcs, nil), nil, mp, do: Map.get(mp, key, nil)
  ```
  """
  defmacro casemapx(expr, other, xvar, do: clause) do
    quote do
      case unquote(expr) do
        %{__struct__: _} -> unquote(other)
        unquote(xvar) when is_map(unquote(xvar)) -> unquote(clause)
        _ -> unquote(other)
      end
    end
  end

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

  # @compile {:inline, merge: 2}
  @spec merge(t, t) :: t
  def merge(a, b), do: Map.merge(a, b, &resolver/3)

  # @compile {:inline, get: 2, get: 3}
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

  # @compile {:inline, getp: 2, getp: 3}
  @spec getp(t | :undefined, any, any) :: any
  def getp(s, key, defa \\ :undefined) do
    case s do
      :undefined ->
        defa

      _ ->
        case Map.fetch(s, key) do
          {:ok, val} -> val
          :error -> defa
        end
    end
  end

  # @compile {:inline, fetch: 2}
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

  # @compile {:inline, fetchp: 2}
  @spec fetchp(t | :undefined, any) :: {:ok, any} | :error
  def fetchp(s, key) do
    case s do
      :undefined -> :error
      _ -> Map.fetch(s, key)
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
        casemap s do
          upd =
            case Map.fetch(s, key) do
              {:ok, map} -> update(map, rest, val)
              :error -> make_from_lst(rest, val)
            end

          Map.put(s, key, upd)
        else
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
        casemap s do
          upd =
            case Map.fetch(s, key) do
              {:ok, map} -> merdate(map, rest, val)
              :error -> make_from_lst(rest, val)
            end

          Map.put(s, key, upd)
        else
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
        casemap s do
          case Map.fetch(s, key) do
            {:ok, map} -> supdate_aux(map, rest, val)
            :error -> smake_from_lst(rest, val)
          end
          |> evaluate_upd(s, key)
        else
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
        casemap s do
          case Map.fetch(s, key) do
            {:ok, map} -> smerdate_aux(map, rest, val)
            :error -> smake_from_lst(rest, val)
          end
          |> evaluate_upd(s, key)
        else
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
                    # Helybenhagyas
                    :undefined
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
  # @compile {:inline, map: 3}
  @spec map(t | :undefined, [any], (any, any -> any)) :: [any]
  def map(s, lst, fnc) do
    casemapx(get(s, lst), [], mp, do: mp |> Enum.map(fn {k, v} -> fnc.(k, v) end) |> List.flatten() |> Enum.filter(fn x -> x != :bump end))
  end

  # @compile {:inline, reduce: 4}
  @spec reduce(t | :undefined, [any], a, (any, any, a -> a)) :: a when a: var
  def reduce(s, lst, acc, fnc) do
    casemapx(get(s, lst), acc, mp, do: mp |> Enum.reduce(acc, fn {k, v}, acc -> fnc.(k, v, acc) end))
  end

  # @compile {:inline, reduce_while: 4}
  @spec reduce_while(t | :undefined, [any], a, (any, any, a -> {:cont, a} | {:halt, a})) :: a when a: var
  def reduce_while(s, lst, acc, fnc) do
    casemapx(get(s, lst), acc, mp, do: mp |> Enum.reduce_while(acc, fn {k, v}, acc -> fnc.(k, v, acc) end))
  end

  @doc """
  Primitiv. A kimenete szurt flatlist.
  """
  # @compile {:inline, mapp: 2}
  @spec mapp(t | :undefined, (any, any -> any)) :: [any]
  def mapp(s, fnc) do
    casemapx(s, [], do: s |> Enum.map(fn {k, v} -> fnc.(k, v) end) |> List.flatten() |> Enum.filter(fn x -> x != :bump end))
  end

  # @compile {:inline, reducep: 3}
  @spec reducep(t | :undefined, a, (any, any, a -> a)) :: a when a: var
  def reducep(s, acc, fnc) do
    casemapx(s, acc, do: s |> Enum.reduce(acc, fn {k, v}, acc -> fnc.(k, v, acc) end))
  end

  # @compile {:inline, reduce_whilep: 3}
  @spec reduce_whilep(t | :undefined, a, (any, any, a -> {:cont, a} | {:halt, a})) :: a when a: var
  def reduce_whilep(s, acc, fnc) do
    casemapx(s, acc, do: s |> Enum.reduce_while(acc, fn {k, v}, acc -> fnc.(k, v, acc) end))
  end

  @type nonunchanged :: :deleted | :inserted | :changed
  @type event :: :unchanged | nonunchanged
  @type fullfun :: (key :: any, event :: event, old :: any, diff :: any, new :: any -> any | :bump)
  @type mapfun :: (key :: any, event :: nonunchanged, old :: any, diff :: any, new :: any -> any | :bump)
  @type redfun(a) :: (key :: any, event :: nonunchanged, old :: any, diff :: any, new :: any, acc :: a -> a)
  @type red_while_fun(a) :: (key :: any, event :: nonunchanged, old :: any, diff :: any, new :: any, acc :: a -> {:cont, a} | {:halt, a})

  @spec latest(nonunchanged, a, a) :: a when a: var
  def latest(event, old, new), do: if(event == :deleted, do: old, else: new)

  @spec full(t | :undefined, t | :undefined, t | :undefined, [any], fullfun) :: [any]
  def full(orig, diff, curr, lst, fnc) do
    orig = get(orig, lst)
    diff = get(diff, lst)
    curr = get(curr, lst)

    casemapx curr, [] do
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
    end
  end

  # @compile {:inline, trackp: 5}
  @spec trackp(nonunchanged, t | :undefined, t | :undefined, t | :undefined, mapfun) :: [any]
  def trackp(orig_event, orig, diff, curr, fnc) do
    case orig_event do
      :deleted ->
        mapp(orig, fn k, v -> fnc.(k, :deleted, v, :undefined, :undefined) end)

      :changed ->
        mapp(diff, fn k, v ->
          # Itt `orig` biztosan `Map`!
          case v do
            :undefined ->
              # Itt bizotsan benne is van `orig`-ban!
              fnc.(k, :deleted, Map.get(orig, k), :undefined, :undefined)

            _ ->
              case Map.fetch(orig, k) do
                :error -> fnc.(k, :inserted, :undefined, v, v)
                {:ok, v2x} -> fnc.(k, :changed, v2x, v, Map.get(curr, k))
              end
          end
        end)

      :inserted ->
        mapp(curr, fn k, v -> fnc.(k, :inserted, :undefined, v, v) end)
    end
  end

  # @compile {:inline, track_reducep: 6}
  @spec track_reducep(nonunchanged, t | :undefined, t | :undefined, t | :undefined, a, redfun(a)) :: a when a: var
  def track_reducep(orig_event, orig, diff, curr, acc, fnc) do
    case orig_event do
      :deleted ->
        reducep(orig, acc, fn k, v, acc -> fnc.(k, :deleted, v, :undefined, :undefined, acc) end)

      :changed ->
        reducep(diff, acc, fn k, v, acc ->
          # Itt `orig` biztosan `Map`!
          case v do
            :undefined ->
              # Itt bizotsan benne is van `orig`-ban!
              fnc.(k, :deleted, Map.get(orig, k), :undefined, :undefined, acc)

            _ ->
              case Map.fetch(orig, k) do
                :error -> fnc.(k, :inserted, :undefined, v, v, acc)
                {:ok, v2x} -> fnc.(k, :changed, v2x, v, Map.get(curr, k), acc)
              end
          end
        end)

      :inserted ->
        reducep(curr, acc, fn k, v, acc -> fnc.(k, :inserted, :undefined, v, v, acc) end)
    end
  end

  # @compile {:inline, track_reduce_whilep: 6}
  @spec track_reduce_whilep(nonunchanged, t | :undefined, t | :undefined, t | :undefined, a, red_while_fun(a)) :: a when a: var
  def track_reduce_whilep(orig_event, orig, diff, curr, acc, fnc) do
    case orig_event do
      :deleted ->
        reduce_whilep(orig, acc, fn k, v, acc -> fnc.(k, :deleted, v, :undefined, :undefined, acc) end)

      :changed ->
        reduce_whilep(diff, acc, fn k, v, acc ->
          # Itt `orig` biztosan `Map`!
          case v do
            :undefined ->
              # Itt bizotsan benne is van `orig`-ban!
              fnc.(k, :deleted, Map.get(orig, k), :undefined, :undefined, acc)

            _ ->
              case Map.fetch(orig, k) do
                :error -> fnc.(k, :inserted, :undefined, v, v, acc)
                {:ok, v2x} -> fnc.(k, :changed, v2x, v, Map.get(curr, k), acc)
              end
          end
        end)

      :inserted ->
        reduce_whilep(curr, acc, fn k, v, acc -> fnc.(k, :inserted, :undefined, v, v, acc) end)
    end
  end

  # @compile {:inline, track: 5}
  @spec track(t | :undefined, t | :undefined, t | :undefined, [any], mapfun) :: [any]
  def track(orig, diff, curr, lst, fnc) do
    orig = get(orig, lst)

    case orig do
      :undefined ->
        # Itt `orig == :undefined` sajnos lehetseges. Pelda: `lst == ["data"] and k == "14400"`.
        # Tovabba ez ujonnan kerult beszurasra.
        # Mivel masodik szint, ezert aztan siman lehet, hogy a `k == "14400"` kulcs nem is letezett azelott.
        # Ekkor viszont biztosan `:insert`.
        map(diff, lst, fn k, v -> fnc.(k, :inserted, :undefined, v, v) end)

      _ ->
        curr = get(curr, lst)

        map(diff, lst, fn k, v ->
          case v do
            # Itt `orig` biztosan `Map`!
            :undefined ->
              # Itt bizotsan benne is van `orig`-ban!
              fnc.(k, :deleted, Map.get(orig, k), :undefined, :undefined)

            _ ->
              case Map.fetch(orig, k) do
                :error ->
                  fnc.(k, :inserted, :undefined, v, v)

                {:ok, v2x} ->
                  # Itt `Map.get(curr, k) == v` NEM BIZTOS, hogy igaz,
                  # mert pl. ha az objektum egy struktura, akkor `v` siman lehet reszleges (kulonbseg)
                  fnc.(k, :changed, v2x, v, Map.get(curr, k))
              end
          end
        end)
    end
  end

  # @compile {:inline, track_reduce: 6}
  @spec track_reduce(t | :undefined, t | :undefined, t | :undefined, [any], a, redfun(a)) :: a when a: var
  def track_reduce(orig, diff, curr, lst, acc, fnc) do
    orig = get(orig, lst)

    case orig do
      :undefined ->
        # Itt `orig == :undefined` sajnos lehetseges. Pelda: `lst == ["data"] and k == "14400"`.
        # Tovabba ez ujonnan kerult beszurasra.
        # Mivel masodik szint, ezert aztan siman lehet, hogy a `k == "14400"` kulcs nem is letezett azelott.
        # Ekkor viszont biztosan `:insert`.
        reduce(diff, lst, acc, fn k, v, acc -> fnc.(k, :inserted, :undefined, v, v, acc) end)

      _ ->
        curr = get(curr, lst)

        reduce(diff, lst, acc, fn k, v, acc ->
          case v do
            # Itt `orig` biztosan `Map`!
            :undefined ->
              # Itt bizotsan benne is van `orig`-ban!
              fnc.(k, :deleted, Map.get(orig, k), :undefined, :undefined, acc)

            _ ->
              case Map.fetch(orig, k) do
                :error ->
                  fnc.(k, :inserted, :undefined, v, v, acc)

                {:ok, v2x} ->
                  # Itt `Map.get(curr, k) == v` NEM BIZTOS, hogy igaz,
                  # mert pl. ha az objektum egy struktura, akkor `v` siman lehet reszleges (kulonbseg)
                  fnc.(k, :changed, v2x, v, Map.get(curr, k), acc)
              end
          end
        end)
    end
  end

  # @compile {:inline, track_reduce_while: 6}
  @spec track_reduce_while(t | :undefined, t | :undefined, t | :undefined, [any], a, red_while_fun(a)) :: a when a: var
  def track_reduce_while(orig, diff, curr, lst, acc, fnc) do
    orig = get(orig, lst)

    case orig do
      :undefined ->
        # Itt `orig == :undefined` sajnos lehetseges. Pelda: `lst == ["data"] and k == "14400"`.
        # Tovabba ez ujonnan kerult beszurasra.
        # Mivel masodik szint, ezert aztan siman lehet, hogy a `k == "14400"` kulcs nem is letezett azelott.
        # Ekkor viszont biztosan `:insert`.
        reduce_while(diff, lst, acc, fn k, v, acc -> fnc.(k, :inserted, :undefined, v, v, acc) end)

      _ ->
        curr = get(curr, lst)

        reduce_while(diff, lst, acc, fn k, v, acc ->
          case v do
            # Itt `orig` biztosan `Map`!
            :undefined ->
              # Itt bizotsan benne is van `orig`-ban!
              fnc.(k, :deleted, Map.get(orig, k), :undefined, :undefined, acc)

            _ ->
              case Map.fetch(orig, k) do
                :error ->
                  fnc.(k, :inserted, :undefined, v, v, acc)

                {:ok, v2x} ->
                  # Itt `Map.get(curr, k) == v` NEM BIZTOS, hogy igaz,
                  # mert pl. ha az objektum egy struktura, akkor `v` siman lehet reszleges (kulonbseg)
                  fnc.(k, :changed, v2x, v, Map.get(curr, k), acc)
              end
          end
        end)
    end
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

  # @compile {:inline, map2: 3}
  @spec map2(t | :undefined, [any], (any, any, any -> any)) :: [any]
  def map2(s, lst, fnc) do
    map(s, lst, fn k, v ->
      mapp(v, &fnc.(k, &1, &2))
    end)
  end

  # @compile {:inline, reduce2: 4}
  @spec reduce2(t | :undefined, [any], a, (any, any, any, a -> a)) :: a when a: var
  def reduce2(s, lst, acc, fnc) do
    reduce(s, lst, acc, fn k, v, acc ->
      reducep(v, acc, &fnc.(k, &1, &2, &3))
    end)
  end

  # @compile {:inline, reduce_while2: 4}
  @spec reduce_while2(t | :undefined, [any], a, (any, any, any, a -> {:cont, a} | {:halt, a})) :: a when a: var
  def reduce_while2(s, lst, acc, fnc) do
    reduce_while(s, lst, acc, fn k, v, acc ->
      reduce_whilep(v, acc, &fnc.(k, &1, &2, &3))
    end)
  end

  # @compile {:inline, mapp2: 2}
  @spec mapp2(t | :undefined, (any, any, any -> any)) :: [any]
  def mapp2(s, fnc) do
    mapp(s, fn k, v ->
      mapp(v, &fnc.(k, &1, &2))
    end)
  end

  # @compile {:inline, reducep2: 3}
  @spec reducep2(t | :undefined, a, (any, any, any, a -> a)) :: a when a: var
  def reducep2(s, acc, fnc) do
    reducep(s, acc, fn k, v, acc ->
      reducep(v, acc, &fnc.(k, &1, &2, &3))
    end)
  end

  # @compile {:inline, reduce_whilep2: 3}
  @spec reduce_whilep2(t | :undefined, a, (any, any, any, a -> {:cont, a} | {:halt, a})) :: a when a: var
  def reduce_whilep2(s, acc, fnc) do
    reduce_whilep(s, acc, fn k, v, acc ->
      reduce_whilep(v, acc, &fnc.(k, &1, &2, &3))
    end)
  end

  @type mapfun2 :: (key1 :: any, key2 :: any, event :: nonunchanged, old :: any, diff :: any, new :: any -> any | :bump)
  @type redfun2(a) :: (key1 :: any, key2 :: any, event :: nonunchanged, old :: any, diff :: any, new :: any, acc :: a -> a)
  @type red_while_fun2(a) :: (key1 :: any, key2 :: any, event :: nonunchanged, old :: any, diff :: any, new :: any, acc :: a -> {:cont, a} | {:halt, a})

  # @compile {:inline, track2: 5}
  @spec track2(t | :undefined, t | :undefined, t | :undefined, [any], mapfun2) :: [any]
  def track2(orig, diff, curr, lst, fnc) do
    track(orig, diff, curr, lst, fn k, event, ori, v, cur ->
      trackp(event, ori, v, cur, &{fnc.(k, &1, &2, &3, &4, &5)})
    end)
  end

  # @compile {:inline, track_reduce2: 6}
  @spec track_reduce2(t | :undefined, t | :undefined, t | :undefined, [any], a, redfun2(a)) :: a when a: var
  def track_reduce2(orig, diff, curr, lst, acc, fnc) do
    track_reduce(orig, diff, curr, lst, acc, fn k, event, ori, v, cur, acc ->
      track_reducep(event, ori, v, cur, acc, &{fnc.(k, &1, &2, &3, &4, &5, &6)})
    end)
  end

  # @compile {:inline, track_reduce_while2: 6}
  @spec track_reduce_while2(t | :undefined, t | :undefined, t | :undefined, [any], a, red_while_fun2(a)) :: a when a: var
  def track_reduce_while2(orig, diff, curr, lst, acc, fnc) do
    track_reduce_while(orig, diff, curr, lst, acc, fn k, event, ori, v, cur, acc ->
      track_reduce_whilep(event, ori, v, cur, acc, &{fnc.(k, &1, &2, &3, &4, &5, &6)})
    end)
  end

  # @compile {:inline, trackp2: 5}
  @spec trackp2(nonunchanged, t | :undefined, t | :undefined, t | :undefined, mapfun2) :: [any]
  def trackp2(oevent, orig, diff, curr, fnc) do
    trackp(oevent, orig, diff, curr, fn k, event, ori, v, cur ->
      trackp(event, ori, v, cur, &{fnc.(k, &1, &2, &3, &4, &5)})
    end)
  end

  # @compile {:inline, track_reducep2: 6}
  @spec track_reducep2(nonunchanged, t | :undefined, t | :undefined, t | :undefined, a, redfun2(a)) :: a when a: var
  def track_reducep2(oevent, orig, diff, curr, acc, fnc) do
    track_reducep(oevent, orig, diff, curr, acc, fn k, event, ori, v, cur, acc ->
      track_reducep(event, ori, v, cur, acc, &{fnc.(k, &1, &2, &3, &4, &5, &6)})
    end)
  end

  # @compile {:inline, track_reduce_while2: 6}
  @spec track_reduce_whilep2(nonunchanged, t | :undefined, t | :undefined, t | :undefined, a, red_while_fun2(a)) :: a when a: var
  def track_reduce_whilep2(oevent, orig, diff, curr, acc, fnc) do
    track_reduce_whilep(oevent, orig, diff, curr, acc, fn k, event, ori, v, cur, acc ->
      track_reduce_whilep(event, ori, v, cur, acc, &{fnc.(k, &1, &2, &3, &4, &5, &6)})
    end)
  end

  ######          ##     ##    ###    ########   #######        ## ########  ######## ########  ##     ##  ######  ########  #######           ######
  ##              ###   ###   ## ##   ##     ## ##     ##      ##  ##     ## ##       ##     ## ##     ## ##    ## ##       ##     ##              ##
  ##              #### ####  ##   ##  ##     ##        ##     ##   ##     ## ##       ##     ## ##     ## ##       ##              ##              ##
  ##              ## ### ## ##     ## ########   #######     ##    ########  ######   ##     ## ##     ## ##       ######    #######               ##
  ##              ##     ## ######### ##               ##   ##     ##   ##   ##       ##     ## ##     ## ##       ##              ##              ##
  ##              ##     ## ##     ## ##        ##     ##  ##      ##    ##  ##       ##     ## ##     ## ##    ## ##       ##     ##              ##
  ######          ##     ## ##     ## ##         #######  ##       ##     ## ######## ########   #######   ######  ########  #######           ######

  # @compile {:inline, map3: 3}
  @spec map3(t | :undefined, [any], (any, any, any, any -> any)) :: [any]
  def map3(s, lst, fnc) do
    map(s, lst, fn k, v ->
      mapp2(v, &fnc.(k, &1, &2, &3))
    end)
  end

  # @compile {:inline, reduce3: 4}
  @spec reduce3(t | :undefined, [any], a, (any, any, any, any, a -> a)) :: a when a: var
  def reduce3(s, lst, acc, fnc) do
    reduce(s, lst, acc, fn k, v, acc ->
      reducep2(v, acc, &fnc.(k, &1, &2, &3, &4))
    end)
  end

  # @compile {:inline, reduce_while3: 4}
  @spec reduce_while3(t | :undefined, [any], a, (any, any, any, any, a -> {:cont, a} | {:halt, a})) :: a when a: var
  def reduce_while3(s, lst, acc, fnc) do
    reduce_while(s, lst, acc, fn k, v, acc ->
      reduce_whilep2(v, acc, &fnc.(k, &1, &2, &3, &4))
    end)
  end

  # @compile {:inline, mapp3: 2}
  @spec mapp3(t | :undefined, (any, any, any, any -> any)) :: [any]
  def mapp3(s, fnc) do
    mapp(s, fn k, v ->
      mapp2(v, &fnc.(k, &1, &2, &3))
    end)
  end

  # @compile {:inline, reducep3: 3}
  @spec reducep3(t | :undefined, a, (any, any, any, any, a -> a)) :: a when a: var
  def reducep3(s, acc, fnc) do
    reducep(s, acc, fn k, v, acc ->
      reducep2(v, acc, &fnc.(k, &1, &2, &3, &4))
    end)
  end

  # @compile {:inline, reduce_whilep3: 3}
  @spec reduce_whilep3(t | :undefined, a, (any, any, any, any, a -> {:cont, a} | {:halt, a})) :: a when a: var
  def reduce_whilep3(s, acc, fnc) do
    reduce_whilep(s, acc, fn k, v, acc ->
      reduce_whilep2(v, acc, &fnc.(k, &1, &2, &3, &4))
    end)
  end

  @type mapfun3 :: (key1 :: any, key2 :: any, key3 :: any, event :: nonunchanged, old :: any, diff :: any, new :: any -> any | :bump)
  @type redfun3(a) :: (key1 :: any, key2 :: any, key3 :: any, event :: nonunchanged, old :: any, diff :: any, new :: any, acc :: a -> a)
  @type red_while_fun3(a) :: (key1 :: any, key2 :: any, key3 :: any, event :: nonunchanged, old :: any, diff :: any, new :: any, acc :: a -> {:cont, a} | {:halt, a})

  # @compile {:inline, track3: 5}
  @spec track3(t | :undefined, t | :undefined, t | :undefined, [any], mapfun3) :: [any]
  def track3(orig, diff, curr, lst, fnc) do
    track(orig, diff, curr, lst, fn k, event, ori, v, cur ->
      trackp2(event, ori, v, cur, &{fnc.(k, &1, &2, &3, &4, &5, &6)})
    end)
  end

  # @compile {:inline, track_reduce3: 6}
  @spec track_reduce3(t | :undefined, t | :undefined, t | :undefined, [any], a, redfun3(a)) :: a when a: var
  def track_reduce3(orig, diff, curr, lst, acc, fnc) do
    track_reduce(orig, diff, curr, lst, acc, fn k, event, ori, v, cur, acc ->
      track_reducep2(event, ori, v, cur, acc, &{fnc.(k, &1, &2, &3, &4, &5, &6, &7)})
    end)
  end

  # @compile {:inline, track_reduce_while3: 6}
  @spec track_reduce_while3(t | :undefined, t | :undefined, t | :undefined, [any], a, red_while_fun3(a)) :: a when a: var
  def track_reduce_while3(orig, diff, curr, lst, acc, fnc) do
    track_reduce_while(orig, diff, curr, lst, acc, fn k, event, ori, v, cur, acc ->
      track_reduce_whilep2(event, ori, v, cur, acc, &{fnc.(k, &1, &2, &3, &4, &5, &6, &7)})
    end)
  end

  # @compile {:inline, trackp3: 5}
  @spec trackp3(nonunchanged, t | :undefined, t | :undefined, t | :undefined, mapfun3) :: [any]
  def trackp3(oevent, orig, diff, curr, fnc) do
    trackp(oevent, orig, diff, curr, fn k, event, ori, v, cur ->
      trackp2(event, ori, v, cur, &{fnc.(k, &1, &2, &3, &4, &5, &6)})
    end)
  end

  # @compile {:inline, track_reducep3: 6}
  @spec track_reducep3(nonunchanged, t | :undefined, t | :undefined, t | :undefined, a, redfun3(a)) :: a when a: var
  def track_reducep3(oevent, orig, diff, curr, acc, fnc) do
    track_reducep(oevent, orig, diff, curr, acc, fn k, event, ori, v, cur, acc ->
      track_reducep2(event, ori, v, cur, acc, &{fnc.(k, &1, &2, &3, &4, &5, &6, &7)})
    end)
  end

  # @compile {:inline, track_reduce_while3: 6}
  @spec track_reduce_whilep3(nonunchanged, t | :undefined, t | :undefined, t | :undefined, a, red_while_fun3(a)) :: a when a: var
  def track_reduce_whilep3(oevent, orig, diff, curr, acc, fnc) do
    track_reduce_whilep(oevent, orig, diff, curr, acc, fn k, event, ori, v, cur, acc ->
      track_reduce_whilep2(event, ori, v, cur, acc, &{fnc.(k, &1, &2, &3, &4, &5, &6, &7)})
    end)
  end

  ######          ##     ##    ###    ########  ##              ## ########  ######## ########  ##     ##  ######  ######## ##                 ######
  ##              ###   ###   ## ##   ##     ## ##    ##       ##  ##     ## ##       ##     ## ##     ## ##    ## ##       ##    ##               ##
  ##              #### ####  ##   ##  ##     ## ##    ##      ##   ##     ## ##       ##     ## ##     ## ##       ##       ##    ##               ##
  ##              ## ### ## ##     ## ########  ##    ##     ##    ########  ######   ##     ## ##     ## ##       ######   ##    ##               ##
  ##              ##     ## ######### ##        #########   ##     ##   ##   ##       ##     ## ##     ## ##       ##       #########              ##
  ##              ##     ## ##     ## ##              ##   ##      ##    ##  ##       ##     ## ##     ## ##    ## ##             ##               ##
  ######          ##     ## ##     ## ##              ##  ##       ##     ## ######## ########   #######   ######  ########       ##           ######

  # @compile {:inline, map4: 3}
  @spec map4(t | :undefined, [any], (any, any, any, any, any -> any)) :: [any]
  def map4(s, lst, fnc) do
    map(s, lst, fn k, v ->
      mapp3(v, &fnc.(k, &1, &2, &3, &4))
    end)
  end

  # @compile {:inline, reduce4: 4}
  @spec reduce4(t | :undefined, [any], a, (any, any, any, any, any, a -> a)) :: a when a: var
  def reduce4(s, lst, acc, fnc) do
    reduce(s, lst, acc, fn k, v, acc ->
      reducep3(v, acc, &fnc.(k, &1, &2, &3, &4, &5))
    end)
  end

  # @compile {:inline, reduce_while4: 4}
  @spec reduce_while4(t | :undefined, [any], a, (any, any, any, any, any, a -> {:cont, a} | {:halt, a})) :: a when a: var
  def reduce_while4(s, lst, acc, fnc) do
    reduce_while(s, lst, acc, fn k, v, acc ->
      reduce_whilep3(v, acc, &fnc.(k, &1, &2, &3, &4, &5))
    end)
  end

  # @compile {:inline, mapp4: 2}
  @spec mapp4(t | :undefined, (any, any, any, any, any -> any)) :: [any]
  def mapp4(s, fnc) do
    mapp(s, fn k, v ->
      mapp3(v, &fnc.(k, &1, &2, &3, &4))
    end)
  end

  # @compile {:inline, reducep4: 3}
  @spec reducep4(t | :undefined, a, (any, any, any, any, any, a -> a)) :: a when a: var
  def reducep4(s, acc, fnc) do
    reducep(s, acc, fn k, v, acc ->
      reducep3(v, acc, &fnc.(k, &1, &2, &3, &4, &5))
    end)
  end

  # @compile {:inline, reduce_whilep4: 3}
  @spec reduce_whilep4(t | :undefined, a, (any, any, any, any, any, a -> {:cont, a} | {:halt, a})) :: a when a: var
  def reduce_whilep4(s, acc, fnc) do
    reduce_whilep(s, acc, fn k, v, acc ->
      reduce_whilep3(v, acc, &fnc.(k, &1, &2, &3, &4, &5))
    end)
  end

  @type mapfun4 :: (key1 :: any, key2 :: any, key3 :: any, key4 :: any, event :: nonunchanged, old :: any, diff :: any, new :: any -> any | :bump)
  @type redfun4(a) :: (key1 :: any, key2 :: any, key3 :: any, key4 :: any, event :: nonunchanged, old :: any, diff :: any, new :: any, acc :: a -> a)
  @type red_while_fun4(a) :: (key1 :: any, key2 :: any, key3 :: any, key4 :: any, event :: nonunchanged, old :: any, diff :: any, new :: any, acc :: a -> {:cont, a} | {:halt, a})

  # @compile {:inline, track4: 5}
  @spec track4(t | :undefined, t | :undefined, t | :undefined, [any], mapfun4) :: [any]
  def track4(orig, diff, curr, lst, fnc) do
    track(orig, diff, curr, lst, fn k, event, ori, v, cur ->
      trackp3(event, ori, v, cur, &{fnc.(k, &1, &2, &3, &4, &5, &6, &7)})
    end)
  end

  # @compile {:inline, track_reduce4: 6}
  @spec track_reduce4(t | :undefined, t | :undefined, t | :undefined, [any], a, redfun4(a)) :: a when a: var
  def track_reduce4(orig, diff, curr, lst, acc, fnc) do
    track_reduce(orig, diff, curr, lst, acc, fn k, event, ori, v, cur, acc ->
      track_reducep3(event, ori, v, cur, acc, &{fnc.(k, &1, &2, &3, &4, &5, &6, &7, &8)})
    end)
  end

  # @compile {:inline, track_reduce_while4: 6}
  @spec track_reduce_while4(t | :undefined, t | :undefined, t | :undefined, [any], a, red_while_fun4(a)) :: a when a: var
  def track_reduce_while4(orig, diff, curr, lst, acc, fnc) do
    track_reduce_while(orig, diff, curr, lst, acc, fn k, event, ori, v, cur, acc ->
      track_reduce_whilep3(event, ori, v, cur, acc, &{fnc.(k, &1, &2, &3, &4, &5, &6, &7, &8)})
    end)
  end

  # @compile {:inline, trackp4: 5}
  @spec trackp4(nonunchanged, t | :undefined, t | :undefined, t | :undefined, mapfun4) :: [any]
  def trackp4(oevent, orig, diff, curr, fnc) do
    trackp(oevent, orig, diff, curr, fn k, event, ori, v, cur ->
      trackp3(event, ori, v, cur, &{fnc.(k, &1, &2, &3, &4, &5, &6, &7)})
    end)
  end

  # @compile {:inline, track_reducep4: 6}
  @spec track_reducep4(nonunchanged, t | :undefined, t | :undefined, t | :undefined, a, redfun4(a)) :: a when a: var
  def track_reducep4(oevent, orig, diff, curr, acc, fnc) do
    track_reducep(oevent, orig, diff, curr, acc, fn k, event, ori, v, cur, acc ->
      track_reducep3(event, ori, v, cur, acc, &{fnc.(k, &1, &2, &3, &4, &5, &6, &7, &8)})
    end)
  end

  # @compile {:inline, track_reduce_while4: 6}
  @spec track_reduce_whilep4(nonunchanged, t | :undefined, t | :undefined, t | :undefined, a, red_while_fun4(a)) :: a when a: var
  def track_reduce_whilep4(oevent, orig, diff, curr, acc, fnc) do
    track_reduce_whilep(oevent, orig, diff, curr, acc, fn k, event, ori, v, cur, acc ->
      track_reduce_whilep3(event, ori, v, cur, acc, &{fnc.(k, &1, &2, &3, &4, &5, &6, &7, &8)})
    end)
  end

  # defmodule
end
