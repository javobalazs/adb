alias ADB.Mlmap

defmodule Mlmap do
  @vsn "0.4.0"
  @moduledoc """
  Tobbszintu map-ek kezelese.

  a = %{}
  a = ADB.Mlmap.update(a, ["spanning", "folder", "show"], true)
  a = ADB.Mlmap.update(a, ["spanning", "c1", "folder"], true)
  a = ADB.Mlmap.update(a, ["spanning", "c2", "folder"], true)
  a = ADB.Mlmap.update(a, ["spanning", "v11", "c1"], true)
  a = ADB.Mlmap.update(a, ["spanning", "v12", "c1"], true)
  # a = ADB.Mlmap.update(a, ["spanning", "v12", "c2"], true)
  # a = ADB.Mlmap.update(a, ["spanning", "v21", "c2"], true)
  a = ADB.Mlmap.update(a, ["spanning", "o111", "v11"], true)
  a = ADB.Mlmap.update(a, ["spanning", "o112", "v11"], true)
  a = ADB.Mlmap.update(a, ["spanning", "o121", "v12"], true)
  a = ADB.Mlmap.update(a, ["spanning", "o122", "v12"], true)
  a = ADB.Mlmap.update(a, ["spanning", "o123", "v12"], true)
  a = ADB.Mlmap.update(a, ["spanning", "o211", "v21"], true)
  a = ADB.Mlmap.update(a, ["spanning", "o212", "v21"], true)
  a = ADB.Mlmap.update(a, ["spanning", "o213", "v21"], true)

  orig = a

  da = %{}
  # da = ADB.Mlmap.update(da, ["spanning", "v12", "c2"], :undefined)
  # a = ADB.Mlmap.supdate(a, ["spanning", "v12", "c2"], :undefined)

  da = ADB.Mlmap.update(da, ["spanning", "c2"], :undefined)
  {a,x} = ADB.Mlmap.supdate(a, ["spanning", "c2"], :undefined)
  da = ADB.Mlmap.update(da, ["spanning", "v21"], :undefined)
  {a,x} = ADB.Mlmap.supdate(a, ["spanning", "v21"], :undefined)
  da = ADB.Mlmap.update(da, ["spanning", "o211"], :undefined)
  {a,x} = ADB.Mlmap.supdate(a, ["spanning", "o211"], :undefined)
  da = ADB.Mlmap.update(da, ["spanning", "o212"], :undefined)
  {a,x} = ADB.Mlmap.supdate(a, ["spanning", "o212"], :undefined)
  da = ADB.Mlmap.update(da, ["spanning", "o213"], :undefined)
  {a,x} = ADB.Mlmap.supdate(a, ["spanning", "o213"], :undefined)
  da = ADB.Mlmap.update(da, ["spanning", "c2", "folder"], :undefined)
  {a,x} = ADB.Mlmap.supdate(a, ["spanning", "c2", "folder"], :undefined)
  ADB.Mlmap.filter(da, orig)


  @vsn `"#{@vsn}"`
  """

  require Util
  Util.arrow_assignment()

  @typedoc """
  Ez elvileg nem tartalmazza a metanyelvi `:undefined`-et.
  """
  @type t :: Map.t()

  @typedoc """
  Itt elvileg komolyan vesszuk a metanyelvi `:undefined`-et.
  """
  @type t_diff :: t | :undefined

  # require Logger

  ######          ##     ## ######## #### ##       #### ######## ##    ##          ######
  ##              ##     ##    ##     ##  ##        ##     ##     ##  ##               ##
  ##              ##     ##    ##     ##  ##        ##     ##      ####                ##
  ##              ##     ##    ##     ##  ##        ##     ##       ##                 ##
  ##              ##     ##    ##     ##  ##        ##     ##       ##                 ##
  ##              ##     ##    ##     ##  ##        ##     ##       ##                 ##
  ######           #######     ##    #### ######## ####    ##       ##             ######

  @doc """
  - Ha `expr` (egy valtozo) egy map (de nem struct), akkor `clause`.
  - Kulonben `other`.

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
  - Ha `expr` egy map (de nem struct), akkor `clause`, es `xvar` fogja tartalmazni `expr` erteket.
  - Kulonben `other`.

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
  - Ha `expr` (egy valtozo) egy map (de nem struct), akkor `clause`.
  - Kulonben `other`.

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
  - Ha `expr` egy map (de nem struct), akkor `clause`, es `xvar` fogja tartalmazni `expr` erteket.
  - Kulonben `other`.

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

  @doc """
  - Ha `expr` (egy valtozo) egy map (de nem struct), akkor `clause`.
  - Ha `:undefined`, akkor `undefblock`.
  - Kulonben `other`.

  ```elixir

  x = casemap v, do: Map.get(v, key, nil), else: nil, catch: :deleted
  ```
  """
  defmacro ucasemap(expr, do: clause, else: other, catch: undefblock) do
    quote do
      case unquote(expr) do
        %{__struct__: _} -> unquote(other)
        y when is_map(y) -> unquote(clause)
        :undefined -> unquote(undefblock)
        _ -> unquote(other)
      end
    end
  end

  @doc """
  - Ha `expr` egy map (de nem struct), akkor `clause`, es `xvar` fogja tartalmazni `expr` erteket.
  - Ha `:undefined`, akkor `undefblock`.
  - Kulonben `other`.

  Ez akkor hasznos, ha `expr` egy tenyleges kifejezes.

  ```elixir
  x = casemap Map.get(valami, kulcs, nil), mp, do: Map.get(mp, key, nil), else: nil, catch: :deleted
  ```
  """
  defmacro ucasemap(expr, xvar, do: clause, else: other, catch: undefblock) do
    quote do
      case unquote(expr) do
        %{__struct__: _} -> unquote(other)
        unquote(xvar) when is_map(unquote(xvar)) -> unquote(clause)
        :undefined -> unquote(undefblock)
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
  # @spec get(:undefined, [any], a) :: a when a: var
  # @spec get(t, [], any) :: t
  # @spec get(t, nonempty_list(any), any) :: any
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
              {:ok, val} -> get_aux(val, rest, defa)
              :error -> defa
            end
        end
    end
  end

  # @compile {:inline, get_aux: 2, get_aux: 3}
  @spec get_aux(a, [], any) :: a when a: var
  @spec get_aux(t, nonempty_list(any), any) :: any
  def get_aux(s, lst, defa \\ :undefined) do
    case lst do
      [] ->
        s

      [key | rest] ->
        case Map.fetch(s, key) do
          {:ok, val} -> get_aux(val, rest, defa)
          :error -> defa
        end
    end
  end

  # @compile {:inline, getp: 2, getp: 3}
  # @spec getp(:undefined, any, a) :: a when a: var
  # @spec getp(t, any, any) :: any
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

  ######          ##     ## ########  ########          ##    ##    ###    #### ##     ##          ######
  ##              ##     ## ##     ## ##     ##         ###   ##   ## ##    ##  ##     ##              ##
  ##              ##     ## ##     ## ##     ##         ####  ##  ##   ##   ##  ##     ##              ##
  ##              ##     ## ########  ##     ##         ## ## ## ##     ##  ##  ##     ##              ##
  ##              ##     ## ##        ##     ##         ##  #### #########  ##   ##   ##               ##
  ##              ##     ## ##        ##     ##         ##   ### ##     ##  ##    ## ##                ##
  ######           #######  ##        ########  ####### ##    ## ##     ## ####    ###             ######

  @doc """
  Itt nincs metanyelvi ertelme az `:undefined`-nek, az is csak egy ertek.
  """
  # @compile {:inline, update: 3}
  @spec update(t, nonempty_list, any) :: t
  @spec update(any, [], a) :: a when a: var
  def update(s, lst, val) do
    case lst do
      [] ->
        val

      [key | rest] ->
        casemap s do
          case Map.fetch(s, key) do
            {:ok, map} -> update(map, rest, val)
            :error -> make_from_lst(rest, val)
          end >>> upd

          Map.put(s, key, upd)
        else
          %{key => make_from_lst(rest, val)}
        end
    end
  end

  # @compile {:inline, merdate: 3}
  @spec merdate(t, [any], t) :: t
  def merdate(s, lst, val) do
    case lst do
      [] ->
        merge(s, val)

      [key | rest] ->
        casemap s do
          case Map.fetch(s, key) do
            {:ok, map} -> merdate(map, rest, val)
            :error -> make_from_lst(rest, val)
          end >>> upd

          Map.put(s, key, upd)
        else
          %{key => make_from_lst(rest, val)}
        end
    end
  end

  # @compile {:inline, make_from_lst: 2}
  @spec make_from_lst([], a) :: a when a: var
  @spec make_from_lst(nonempty_list(any()), any) :: t
  def make_from_lst(lst, val) do
    case lst do
      [] -> val
      [k | rest] -> %{k => make_from_lst(rest, val)}
    end
  end

  ######          ##     ## ########  ########          ########  #### ######## ########          ######
  ##              ##     ## ##     ## ##     ##         ##     ##  ##  ##       ##                    ##
  ##              ##     ## ##     ## ##     ##         ##     ##  ##  ##       ##                    ##
  ##              ##     ## ########  ##     ##         ##     ##  ##  ######   ######                ##
  ##              ##     ## ##        ##     ##         ##     ##  ##  ##       ##                    ##
  ##              ##     ## ##        ##     ##         ##     ##  ##  ##       ##                    ##
  ######           #######  ##        ########  ####### ########  #### ##       ##                ######

  # defmacro same_check(key, expr) do
  #   quote do
  #     case unquote(expr) do
  #       {:ok, upd} -> {:ok, %{unquote(key) => upd}}
  #       :same -> :same
  #       :undefined -> :undefined
  #     end
  #   end
  # end
  #
  # defmacro eq_check(orig, val) do
  #   quote do
  #     if unquote(orig) == unquote(val), do: :undefined, else: {:ok, unquote(val)}
  #   end
  # end
  #
  # defmacro undefined_check(var, expr) do
  #   quote do
  #     Util.wife(:same, unquote(var) != :undefined, do: {:ok, unquote(expr)})
  #   end
  # end
  #
  # @doc """
  # Itt nincs metanyelvi ertelme az `:undefined`-nek, az is csak egy ertek.
  # """
  # @spec dupdate_aux(t, t_diff, nonempty_list, any) :: :same | {:ok, t}
  # @spec dupdate_aux(a, a, [], a) :: :same | {:ok, a} when a: var
  # @spec dupdate_aux(any, any, [], a) :: {:ok, a} when a: var
  # def dupdate_aux(orig, diff, lst, val) do
  #   case lst do
  #     [] ->
  #       eq_check(orig, val)
  #
  #     [key | rest] ->
  #       casemap diff do
  #         case Map.fetch(diff, key) do
  #           {:ok, map} ->
  #             same_check(key, dupdate_aux(map, rest, val))
  #
  #           :error ->
  #             casemap orig do
  #               case Map.fetch(orig, key) do
  #                 {:ok, map} -> same_check(key, descend(orig, rest, val))
  #                 :error -> undefined_check(val, Map.put(diff, key, make_from_lst(rest, val)))
  #               end
  #             else
  #               undefined_check(val, Map.put(diff, key, make_from_lst(rest, val)))
  #             end
  #         end
  #       else
  #         upd = make_from_lst(rest, val)
  #         %{key => make_from_lst(rest, val)}
  #       end
  #   end
  # end
  #
  # def descend(orig, lst, val) do
  #   case lst do
  #     [] ->
  #       eq_check(orig, val)
  #
  #     [key | rest] ->
  #       casemap orig do
  #         case Map.fetch(orig, key) do
  #           {:ok, map} -> same_check(key, descend(map, rest, val))
  #           :error -> undefined_check(val, %{key => make_from_lst(rest, val)})
  #         end
  #       else
  #         undefined_check(val, %{key => make_from_lst(rest, val)})
  #       end
  #   end
  # end
  #
  # @spec dmerdate(t, [any], any) :: t
  # def dmerdate(s, lst, val) do
  #   case lst do
  #     [] ->
  #       merge(s, val)
  #
  #     [key | rest] ->
  #       casemap s do
  #         upd =
  #           case Map.fetch(s, key) do
  #             {:ok, map} -> merdate(map, rest, val)
  #             :error -> make_from_lst(rest, val)
  #           end
  #
  #         Map.put(s, key, upd)
  #       else
  #         upd = make_from_lst(rest, val)
  #         %{key => upd}
  #       end
  #   end
  # end
  #
  # @spec dmake_from_lst([], a) :: a when a: var
  # @spec dmake_from_lst(nonempty_list(any()), any) :: t
  # def dmake_from_lst(lst, val) do
  #   case lst do
  #     [] -> val
  #     [k | rest] -> %{k => make_from_lst(rest, val)}
  #   end
  # end
  #
  ######          ##     ## ########  ########          ##     ## ######## ########    ###             ######
  ##              ##     ## ##     ## ##     ##         ###   ### ##          ##      ## ##                ##
  ##              ##     ## ##     ## ##     ##         #### #### ##          ##     ##   ##               ##
  ##              ##     ## ########  ##     ##         ## ### ## ######      ##    ##     ##              ##
  ##              ##     ## ##        ##     ##         ##     ## ##          ##    #########              ##
  ##              ##     ## ##        ##     ##         ##     ## ##          ##    ##     ##              ##
  ######           #######  ##        ########  ####### ##     ## ########    ##    ##     ##          ######

  @doc """
  Itt normal adatszerkezetekre alkalmazunk diff-eket, azaz a diff-ben metanyelvi ertelme van az `:undefined`-nek.
  """

  # @spec smerge(t, t_diff) :: :bump | :undefined | {t, t_diff}
  # def smerge(s, diff) do
  # end

  # @compile {:inline, supdate: 3}
  @spec supdate(t, [any], any) :: {t, [any]} | :bump | :undefined
  def supdate(s, lst, val) do
    case val do
      :undefined ->
        supdate_aux_u(s, lst)

      _ ->
        case supdate_aux(s, lst, val) do
          :bump -> :bump
          upd -> {upd, lst}
        end
    end
  end

  # @compile {:inline, supdate_aux: 3}
  @spec supdate_aux(t, nonempty_list(any), any) :: t | :bump
  @spec supdate_aux(any, [], a) :: :bump | a when a: var
  def supdate_aux(s, lst, val) do
    case lst do
      [] ->
        if val == s, do: :bump, else: val

      [key | rest] ->
        casemap s do
          case Map.fetch(s, key) do
            {:ok, map} ->
              case supdate_aux(map, rest, val) do
                :bump -> :bump
                upd -> Map.put(s, key, upd)
              end

            :error ->
              Map.put(s, key, smake_from_lst(rest, val))
          end
        else
          %{key => smake_from_lst(rest, val)}
        end
    end
  end

  # @compile {:inline, supdate_aux_u: 2}
  @spec supdate_aux_u(t, nonempty_list(any)) :: {t, [any]} | :undefined | :bump
  @spec supdate_aux_u(any, []) :: :undefined
  def supdate_aux_u(s, lst) do
    case lst do
      [] ->
        # Itt a torlese a levelnek.
        :undefined

      [key | rest] ->
        casemap s do
          case Map.fetch(s, key) do
            {:ok, map} ->
              case supdate_aux_u(map, rest) do
                :undefined ->
                  s = Map.delete(s, key)
                  if s == %{}, do: :undefined, else: {s, [key]}

                :bump ->
                  :bump

                {upd, rslst} ->
                  {Map.put(s, key, upd), [key | rslst]}
              end

            # Nincs is benne, nem kell torolni
            :error ->
              :bump
          end
        else
          # Itt nem kell csinalni semmit, nincs is benne.
          :bump
        end
    end
  end

  # @compile {:inline, smerdate: 3}
  @spec smerdate(t, [any], t_diff) :: {t, [any], t_diff} | :undefined | :bump
  def smerdate(s, lst, val) do
    case lst do
      [] ->
        Util.wife :undefined, val != :undefined do
          res = merge(s, val) |> normalize()

          Util.wife :undefined, res != %{} do
            if res == s, do: :bump, else: {res, [], val}
          end
        end

      [key | rest] ->
        casemap s do
          case Map.fetch(s, key) do
            {:ok, map} -> smerdate(map, rest, val)
            :error -> n_smake_from_lst(rest, val)
          end >>> upd

          case upd do
            :undefined ->
              s = Map.delete(s, key)
              if s == %{}, do: :undefined, else: {s, lst, :undefined}

            :bump ->
              :bump

            {mp, rslst, nval} ->
              {Map.put(s, key, mp), [key | rslst], nval}
          end
        else
          n_smake_from_lst(rest, val)
        end
    end
  end

  # @compile {:inline, smerdate_n: 3}
  @spec smerdate_n(t, [any], t_diff) :: {t, [any]}
  def smerdate_n(s, lst, val) do
    case lst do
      [] ->
        Util.wife :undefined, val != :undefined do
          res = merge(s, val) |> normalize()

          Util.wife :undefined, res != %{} do
            if res == s, do: :bump, else: {res, []}
          end
        end

      [key | rest] ->
        casemap s do
          case Map.fetch(s, key) do
            {:ok, map} -> smerdate_n(map, rest, val)
            # Nem kell normalizalni, mar az elozo korben normalizalodnia kellett, itt csak insert lehet benne!
            :error -> Util.wife(:undefined, val != :undefined, do: {smake_from_lst(rest, val), rest})
          end >>> upd

          case upd do
            :undefined ->
              s = Map.delete(s, key)
              if s == %{}, do: :undefined, else: {s, lst}

            {mp, rslst} ->
              {Map.put(s, key, mp), [key | rslst]}
          end
        else
          # Nem kell normalizalni, mar az elozo korben normalizalodnia kellett, itt csak insert lehet benne!
          Util.wife(:undefined, val != :undefined, do: {%{key => smake_from_lst(rest, val)}, lst})
        end
    end
  end

  # @compile {:inline, n_smake_from_lst: 2}
  @spec n_smake_from_lst([any], t_diff) :: {t, [any], t_diff} | :undefined
  def n_smake_from_lst(lst, val) do
    Util.wife :undefined, val != :undefined do
      nval = normalize(val)
      if nval == %{}, do: :undefined, else: {smake_from_lst(lst, nval), lst, nval}
    end
  end

  # @compile {:inline, smake_from_lst: 2}
  @spec smake_from_lst([any], t) :: t
  def smake_from_lst(lst, val) do
    case lst do
      [] -> val
      [k | rest] -> %{k => smake_from_lst(rest, val)}
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
  # @compile {:inline, normalize: 1}
  @spec normalize(t_diff) :: t
  def normalize(s) do
    s
    |> Enum.map(fn {k, v} ->
      ucasemap v do
        if Map.size(v) == 0 do
          {k, %{}}
        else
          v = normalize(v)
          if v == %{}, do: :undefined, else: {k, v}
        end
      else
        {k, v}
      catch
        :undefined
      end
    end)
    |> Enum.filter(fn x -> x != :undefined end)
    |> Map.new()
  end

  @doc """
  Egy diff-et optimalizal.
  """
  # @compile {:inline, filter: 3}
  @spec filter(t_diff, t, any) :: t
  def filter(s, s2, meta \\ :undefined) do
    s
    |> Enum.map(fn {k, v} ->
      case Map.fetch(s2, k) do
        {:ok, v2} ->
          ucasemap v do
            casemap v2 do
              if Map.size(v) == 0 do
                # Helybenhagyas
                :bump
              else
                v = filter(v, v2, meta)
                if v == %{}, do: :bump, else: {k, v}
              end
            else
              {k, v}
            end
          else
            if v == v2, do: :bump, else: {k, v}
          catch
            if meta == v2, do: :bump, else: {k, meta}
            # {k, meta}
          end

        :error ->
          case v do
            :undefined -> :bump
            _ -> {k, v}
          end
      end
    end)
    |> Enum.filter(fn x -> x != :bump end)
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
      |> Enum.filter(fn v -> v != :bump end) >>> first

      diff
      |> Enum.filter(fn {_k, v} -> v == :undefined end)
      |> Enum.reduce([], fn {k, _}, acc ->
        ori = Map.get(orig, k)
        [fnc.(k, :deleted, ori, :undefined, :undefined) | acc]
      end)
      |> Enum.filter(fn v -> v != :bump end) >>> second

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
        case diff do
          :undefined ->
            mapp(orig, fn k, v -> fnc.(k, :deleted, v, :undefined, :undefined) end)

          _ ->
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
        end

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
        case diff do
          :undefined ->
            reducep(orig, acc, fn k, v, acc -> fnc.(k, :deleted, v, :undefined, :undefined, acc) end)

          _ ->
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
        end

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
        case diff do
          :undefined ->
            reduce_whilep(orig, acc, fn k, v, acc -> fnc.(k, :deleted, v, :undefined, :undefined, acc) end)

          _ ->
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
        end

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
        diff = get(diff, lst, %{})

        case diff do
          :undefined ->
            mapp(orig, fn k, v -> fnc.(k, :deleted, v, :undefined, :undefined) end)

          _ ->
            curr = get(curr, lst)

            mapp(diff, fn k, v ->
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
        diff = get(diff, lst, %{})

        case diff do
          :undefined ->
            reducep(orig, acc, fn k, v, acc -> fnc.(k, :deleted, v, :undefined, :undefined, acc) end)

          _ ->
            curr = get(curr, lst)

            reducep(diff, acc, fn k, v, acc ->
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
        diff = get(diff, lst, %{})

        case diff do
          :undefined ->
            reduce_whilep(orig, acc, fn k, v, acc -> fnc.(k, :deleted, v, :undefined, :undefined, acc) end)

          _ ->
            curr = get(curr, lst)

            reduce_whilep(diff, acc, fn k, v, acc ->
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
      trackp(event, ori, v, cur, &fnc.(k, &1, &2, &3, &4, &5))
    end)
  end

  # @compile {:inline, track_reduce2: 6}
  @spec track_reduce2(t | :undefined, t | :undefined, t | :undefined, [any], a, redfun2(a)) :: a when a: var
  def track_reduce2(orig, diff, curr, lst, acc, fnc) do
    track_reduce(orig, diff, curr, lst, acc, fn k, event, ori, v, cur, acc ->
      track_reducep(event, ori, v, cur, acc, &fnc.(k, &1, &2, &3, &4, &5, &6))
    end)
  end

  # @compile {:inline, track_reduce_while2: 6}
  @spec track_reduce_while2(t | :undefined, t | :undefined, t | :undefined, [any], a, red_while_fun2(a)) :: a when a: var
  def track_reduce_while2(orig, diff, curr, lst, acc, fnc) do
    track_reduce_while(orig, diff, curr, lst, acc, fn k, event, ori, v, cur, acc ->
      track_reduce_whilep(event, ori, v, cur, acc, &fnc.(k, &1, &2, &3, &4, &5, &6))
    end)
  end

  # @compile {:inline, trackp2: 5}
  @spec trackp2(nonunchanged, t | :undefined, t | :undefined, t | :undefined, mapfun2) :: [any]
  def trackp2(oevent, orig, diff, curr, fnc) do
    trackp(oevent, orig, diff, curr, fn k, event, ori, v, cur ->
      trackp(event, ori, v, cur, &fnc.(k, &1, &2, &3, &4, &5))
    end)
  end

  # @compile {:inline, track_reducep2: 6}
  @spec track_reducep2(nonunchanged, t | :undefined, t | :undefined, t | :undefined, a, redfun2(a)) :: a when a: var
  def track_reducep2(oevent, orig, diff, curr, acc, fnc) do
    track_reducep(oevent, orig, diff, curr, acc, fn k, event, ori, v, cur, acc ->
      track_reducep(event, ori, v, cur, acc, &fnc.(k, &1, &2, &3, &4, &5, &6))
    end)
  end

  # @compile {:inline, track_reduce_while2: 6}
  @spec track_reduce_whilep2(nonunchanged, t | :undefined, t | :undefined, t | :undefined, a, red_while_fun2(a)) :: a when a: var
  def track_reduce_whilep2(oevent, orig, diff, curr, acc, fnc) do
    track_reduce_whilep(oevent, orig, diff, curr, acc, fn k, event, ori, v, cur, acc ->
      track_reduce_whilep(event, ori, v, cur, acc, &fnc.(k, &1, &2, &3, &4, &5, &6))
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
      trackp2(event, ori, v, cur, &fnc.(k, &1, &2, &3, &4, &5, &6))
    end)
  end

  # @compile {:inline, track_reduce3: 6}
  @spec track_reduce3(t | :undefined, t | :undefined, t | :undefined, [any], a, redfun3(a)) :: a when a: var
  def track_reduce3(orig, diff, curr, lst, acc, fnc) do
    track_reduce(orig, diff, curr, lst, acc, fn k, event, ori, v, cur, acc ->
      track_reducep2(event, ori, v, cur, acc, &fnc.(k, &1, &2, &3, &4, &5, &6, &7))
    end)
  end

  # @compile {:inline, track_reduce_while3: 6}
  @spec track_reduce_while3(t | :undefined, t | :undefined, t | :undefined, [any], a, red_while_fun3(a)) :: a when a: var
  def track_reduce_while3(orig, diff, curr, lst, acc, fnc) do
    track_reduce_while(orig, diff, curr, lst, acc, fn k, event, ori, v, cur, acc ->
      track_reduce_whilep2(event, ori, v, cur, acc, &fnc.(k, &1, &2, &3, &4, &5, &6, &7))
    end)
  end

  # @compile {:inline, trackp3: 5}
  @spec trackp3(nonunchanged, t | :undefined, t | :undefined, t | :undefined, mapfun3) :: [any]
  def trackp3(oevent, orig, diff, curr, fnc) do
    trackp(oevent, orig, diff, curr, fn k, event, ori, v, cur ->
      trackp2(event, ori, v, cur, &fnc.(k, &1, &2, &3, &4, &5, &6))
    end)
  end

  # @compile {:inline, track_reducep3: 6}
  @spec track_reducep3(nonunchanged, t | :undefined, t | :undefined, t | :undefined, a, redfun3(a)) :: a when a: var
  def track_reducep3(oevent, orig, diff, curr, acc, fnc) do
    track_reducep(oevent, orig, diff, curr, acc, fn k, event, ori, v, cur, acc ->
      track_reducep2(event, ori, v, cur, acc, &fnc.(k, &1, &2, &3, &4, &5, &6, &7))
    end)
  end

  # @compile {:inline, track_reduce_while3: 6}
  @spec track_reduce_whilep3(nonunchanged, t | :undefined, t | :undefined, t | :undefined, a, red_while_fun3(a)) :: a when a: var
  def track_reduce_whilep3(oevent, orig, diff, curr, acc, fnc) do
    track_reduce_whilep(oevent, orig, diff, curr, acc, fn k, event, ori, v, cur, acc ->
      track_reduce_whilep2(event, ori, v, cur, acc, &fnc.(k, &1, &2, &3, &4, &5, &6, &7))
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
      trackp3(event, ori, v, cur, &fnc.(k, &1, &2, &3, &4, &5, &6, &7))
    end)
  end

  # @compile {:inline, track_reduce4: 6}
  @spec track_reduce4(t | :undefined, t | :undefined, t | :undefined, [any], a, redfun4(a)) :: a when a: var
  def track_reduce4(orig, diff, curr, lst, acc, fnc) do
    track_reduce(orig, diff, curr, lst, acc, fn k, event, ori, v, cur, acc ->
      track_reducep3(event, ori, v, cur, acc, &fnc.(k, &1, &2, &3, &4, &5, &6, &7, &8))
    end)
  end

  # @compile {:inline, track_reduce_while4: 6}
  @spec track_reduce_while4(t | :undefined, t | :undefined, t | :undefined, [any], a, red_while_fun4(a)) :: a when a: var
  def track_reduce_while4(orig, diff, curr, lst, acc, fnc) do
    track_reduce_while(orig, diff, curr, lst, acc, fn k, event, ori, v, cur, acc ->
      track_reduce_whilep3(event, ori, v, cur, acc, &fnc.(k, &1, &2, &3, &4, &5, &6, &7, &8))
    end)
  end

  # @compile {:inline, trackp4: 5}
  @spec trackp4(nonunchanged, t | :undefined, t | :undefined, t | :undefined, mapfun4) :: [any]
  def trackp4(oevent, orig, diff, curr, fnc) do
    trackp(oevent, orig, diff, curr, fn k, event, ori, v, cur ->
      trackp3(event, ori, v, cur, &fnc.(k, &1, &2, &3, &4, &5, &6, &7))
    end)
  end

  # @compile {:inline, track_reducep4: 6}
  @spec track_reducep4(nonunchanged, t | :undefined, t | :undefined, t | :undefined, a, redfun4(a)) :: a when a: var
  def track_reducep4(oevent, orig, diff, curr, acc, fnc) do
    track_reducep(oevent, orig, diff, curr, acc, fn k, event, ori, v, cur, acc ->
      track_reducep3(event, ori, v, cur, acc, &fnc.(k, &1, &2, &3, &4, &5, &6, &7, &8))
    end)
  end

  # @compile {:inline, track_reduce_while4: 6}
  @spec track_reduce_whilep4(nonunchanged, t | :undefined, t | :undefined, t | :undefined, a, red_while_fun4(a)) :: a when a: var
  def track_reduce_whilep4(oevent, orig, diff, curr, acc, fnc) do
    track_reduce_whilep(oevent, orig, diff, curr, acc, fn k, event, ori, v, cur, acc ->
      track_reduce_whilep3(event, ori, v, cur, acc, &fnc.(k, &1, &2, &3, &4, &5, &6, &7, &8))
    end)
  end

  # defmodule
end
