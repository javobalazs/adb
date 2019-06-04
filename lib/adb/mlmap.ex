alias ADB.Mlmap

defmodule Mlmap do
  @vsn "0.4.0"
  @moduledoc """
  Tobbszintu map-ek kezelese.

  # Letrehozas
  iex>  a = %{}
  iex>  ao = %{}
  iex>  diff = %{}
  iex>  {a, x} = ADB.Mlmap.supdate(a, ["spanning", "folder", "show"], true)
  iex>  diff = ADB.Mlmap.dupdate(ao, diff, x, true)
  iex>  {a, x} = ADB.Mlmap.supdate(a, ["spanning", "c2", "folder"], true)
  iex>  diff = ADB.Mlmap.dupdate(ao, diff, x, true)
  iex>  {a, x} = ADB.Mlmap.supdate(a, ["spanning", "v11", "c1"], true)
  iex>  diff = ADB.Mlmap.dupdate(ao, diff, x, true)
  iex>  {a, x} = ADB.Mlmap.supdate(a, ["spanning", "v12", "c1"], true)
  iex>  diff = ADB.Mlmap.dupdate(ao, diff, x, true)
  iex>  {a, x} = ADB.Mlmap.supdate(a, ["spanning", "v12", "c2"], true)
  iex>  diff = ADB.Mlmap.dupdate(ao, diff, x, true)
  iex>  {a, x} = ADB.Mlmap.supdate(a, ["spanning", "v21", "c2"], true)
  iex>  diff = ADB.Mlmap.dupdate(ao, diff, x, true)
  iex>  {a, x} = ADB.Mlmap.supdate(a, ["spanning", "o111", "v11"], true)
  iex>  diff = ADB.Mlmap.dupdate(ao, diff, x, true)
  iex>  {a, x} = ADB.Mlmap.supdate(a, ["spanning", "o112", "v11"], true)
  iex>  diff = ADB.Mlmap.dupdate(ao, diff, x, true)
  iex>  {a, x} = ADB.Mlmap.supdate(a, ["spanning", "o121", "v12"], true)
  iex>  diff = ADB.Mlmap.dupdate(ao, diff, x, true)
  iex>  {a, x} = ADB.Mlmap.supdate(a, ["spanning", "o122", "v12"], true)
  iex>  diff = ADB.Mlmap.dupdate(ao, diff, x, true)
  iex>  {a, x} = ADB.Mlmap.supdate(a, ["spanning", "o123", "v12"], true)
  iex>  diff = ADB.Mlmap.dupdate(ao, diff, x, true)
  iex>  {a, x} = ADB.Mlmap.supdate(a, ["spanning", "o211", "v21"], true)
  iex>  diff = ADB.Mlmap.dupdate(ao, diff, x, true)
  iex>  {a, x} = ADB.Mlmap.supdate(a, ["spanning", "o212", "v21"], true)
  iex>  diff = ADB.Mlmap.dupdate(ao, diff, x, true)
  iex>  {a, x} = ADB.Mlmap.supdate(a, ["spanning", "o213", "v21"], true)
  {%{
     "spanning" => %{
       "c2" => %{"folder" => true},
       "folder" => %{"show" => true},
       "o111" => %{"v11" => true},
       "o112" => %{"v11" => true},
       "o121" => %{"v12" => true},
       "o122" => %{"v12" => true},
       "o123" => %{"v12" => true},
       "o211" => %{"v21" => true},
       "o212" => %{"v21" => true},
       "o213" => %{"v21" => true},
       "v11" => %{"c1" => true},
       "v12" => %{"c1" => true, "c2" => true},
       "v21" => %{"c2" => true}
     }
   }, ["spanning", "o213", "v21"]}
  iex>  diff = ADB.Mlmap.dupdate(ao, diff, x, true)
  iex>  diff == a
  true
  # Ugyanaz
  iex>  ao = a
  iex>  diff = %{}
  iex>  ADB.Mlmap.supdate(a, ["spanning", "folder", "show"], true)
  :bump
  iex>  {a, x} = ADB.Mlmap.supdate(a, ["spanning", "folder", "show", "segg"], true)
  iex>  diff = ADB.Mlmap.dupdate(ao, diff, x, true)
  iex>  {a, x} = ADB.Mlmap.supdate(a, ["spanning", "folder", "show", "segg", "fasz"], true)
  iex>  diff = ADB.Mlmap.dupdate(ao, diff, x, true)
  iex>  {a, x} = ADB.Mlmap.supdate(a, ["spanning", "c2", "folder", "segg", "fasz"], true)
  iex>  diff = ADB.Mlmap.dupdate(ao, diff, x, true)
  iex>  {a, x} = ADB.Mlmap.supdate(a, ["spanning", "folder", "show"], true)
  iex>  diff = ADB.Mlmap.dupdate(ao, diff, x, true)
  iex>  {a, x} = ADB.Mlmap.supdate(a, ["spanning", "c2", "folder"], true)
  iex>  diff = ADB.Mlmap.dupdate(ao, diff, x, true)
  %{}
  # TORLESEK
  iex>  {a, x} = ADB.Mlmap.supdate(a, ["spanning", "v12", "c2"], :undefined)
  iex>  diff = ADB.Mlmap.dupdate(ao, diff, x, :undefined)
  iex>  ADB.Mlmap.supdate(a, ["spanning", "v12", "c2"], :undefined)
  :bump
  iex>  {a, x} = ADB.Mlmap.supdate(a, ["spanning", "c2"], :undefined)
  iex>  diff = ADB.Mlmap.dupdate(ao, diff, x, :undefined)
  iex>  ADB.Mlmap.supdate(a, ["spanning", "c2"], :undefined)
  :bump
  iex>  {a,x} = ADB.Mlmap.supdate(a, ["spanning", "v21"], :undefined)
  iex>  diff = ADB.Mlmap.dupdate(ao, diff, x, :undefined)
  iex>  {a,x} = ADB.Mlmap.supdate(a, ["spanning", "o211"], :undefined)
  iex>  diff = ADB.Mlmap.dupdate(ao, diff, x, :undefined)
  iex>  {a,x} = ADB.Mlmap.supdate(a, ["spanning", "o212"], :undefined)
  iex>  diff = ADB.Mlmap.dupdate(ao, diff, x, :undefined)
  iex>  ddiff = ADB.Mlmap.dmerge(%{}, ao, diff)
  %{
    "spanning" => %{
      "folder" => %{"show" => true},
      "o111" => %{"v11" => true},
      "o112" => %{"v11" => true},
      "o121" => %{"v12" => true},
      "o122" => %{"v12" => true},
      "o123" => %{"v12" => true},
      "o213" => %{"v21" => true},
      "v11" => %{"c1" => true},
      "v12" => %{"c1" => true}
    }
  }
  iex> ddiff == a
  true
  iex>  metadiff = ADB.Mlmap.ddmerge(%{}, ao, diff, "undefined")
  iex>  metadiff == {a, a}
  true
  # KIINDULOALLAPOT A DIFFMERGE TESZTELESEHEZ
  iex> a2 = a; diff2 = diff; ddiff = %{}; ddiff2 = %{}; metadiff = %{}; ometadiff = %{}
  iex> a2
  %{
    "spanning" => %{
      "folder" => %{"show" => true},
      "o111" => %{"v11" => true},
      "o112" => %{"v11" => true},
      "o121" => %{"v12" => true},
      "o122" => %{"v12" => true},
      "o123" => %{"v12" => true},
      "o213" => %{"v21" => true},
      "v11" => %{"c1" => true},
      "v12" => %{"c1" => true}
    }
  }
  iex> diff2
  %{
    "spanning" => %{
      "c2" => :undefined,
      "o211" => :undefined,
      "o212" => :undefined,
      "v12" => %{"c2" => :undefined},
      "v21" => :undefined
    }
  }
  iex>  {a,x} = ADB.Mlmap.supdate(a, ["spanning", "o213"], :undefined)
  iex>  diff = ADB.Mlmap.dupdate(ao, diff, x, :undefined)
  iex>  stepdiff = ADB.Mlmap.make_from_lst(x, :undefined)
  iex>  ddiff = ADB.Mlmap.dmerge(a2, ddiff, stepdiff)
  iex>  {metadiff, dmetadiff} = ADB.Mlmap.ddmerge(a2, metadiff, stepdiff, "undefined")
  iex>  metadiff == ADB.Mlmap.value_transform(ddiff, :undefined, "undefined")
  true
  iex>  {metadiff, :bump} == ADB.Mlmap.smerge(ometadiff, dmetadiff)
  true
  iex>  ddiff2 = ADB.Mlmap.dupdate(a2, ddiff2, x, :undefined)
  iex>  ddiff == ddiff2
  true
  iex>  ADB.Mlmap.supdate(a, ["spanning", "c2", "folder"], :undefined)
  :bump
  iex> ometadiff = metadiff
  iex>  {a,x} = ADB.Mlmap.supdate(a, ["spanning", "v12"], :undefined)
  {%{
     "spanning" => %{
       "folder" => %{"show" => true},
       "o111" => %{"v11" => true},
       "o112" => %{"v11" => true},
       "o121" => %{"v12" => true},
       "o122" => %{"v12" => true},
       "o123" => %{"v12" => true},
       "v11" => %{"c1" => true}
     }
   }, ["spanning", "v12"]}
  iex>  diff = ADB.Mlmap.dupdate(ao, diff, x, :undefined)
  %{
    "spanning" => %{
      "c2" => :undefined,
      "o211" => :undefined,
      "o212" => :undefined,
      "o213" => :undefined,
      "v12" => :undefined,
      "v21" => :undefined
    }
  }
  iex>  stepdiff = ADB.Mlmap.make_from_lst(x, :undefined)
  iex>  ddiff = ADB.Mlmap.dmerge(a2, ddiff, stepdiff)
  iex>  {metadiff, dmetadiff} = ADB.Mlmap.ddmerge(a2, metadiff, stepdiff, "undefined")
  iex>  metadiff == ADB.Mlmap.value_transform(ddiff, :undefined, "undefined")
  true
  iex>  ddiff2 = ADB.Mlmap.dupdate(a2, ddiff2, x, :undefined)
  iex>  ddiff == ddiff2
  true
  iex>  {metadiff, :bump} == ADB.Mlmap.smerge(ometadiff, dmetadiff)
  true
  iex> ometadiff = metadiff
  iex>  {a, x} = ADB.Mlmap.supdate(a, ["spanning", "v12", "c3"], true)
  iex>  diff = ADB.Mlmap.dupdate(ao, diff, x, true)
  %{
    "spanning" => %{
      "c2" => :undefined,
      "o211" => :undefined,
      "o212" => :undefined,
      "o213" => :undefined,
      "v12" => %{"c1" => :undefined, "c2" => :undefined, "c3" => true},
      "v21" => :undefined
    }
  }
  iex>  stepdiff = ADB.Mlmap.make_from_lst(x, true)
  iex>  ddiff = ADB.Mlmap.dmerge(a2, ddiff, stepdiff)
  %{
    "spanning" => %{
      "o213" => :undefined,
      "v12" => %{"c1" => :undefined, "c3" => true}
    }
  }
  iex>  {metadiff, dmetadiff} = ADB.Mlmap.ddmerge(a2, metadiff, stepdiff, "undefined")
  iex>  metadiff == ADB.Mlmap.value_transform(ddiff, :undefined, "undefined")
  true
  iex>  ddiff2 = ADB.Mlmap.dupdate(a2, ddiff2, x, true)
  iex>  ddiff == ddiff2
  true
  iex>  {metadiff, :bump} == ADB.Mlmap.smerge(ometadiff, dmetadiff)
  true
  iex> ometadiff = metadiff
  iex>  {a, x} = ADB.Mlmap.supdate(a, ["spanning", "v12", "c1"], true)
  iex>  diff = ADB.Mlmap.dupdate(ao, diff, x, true)
  %{
    "spanning" => %{
      "c2" => :undefined,
      "o211" => :undefined,
      "o212" => :undefined,
      "o213" => :undefined,
      "v12" => %{"c2" => :undefined, "c3" => true},
      "v21" => :undefined
    }
  }
  iex>  stepdiff = ADB.Mlmap.make_from_lst(x, true)
  iex>  ddiff = ADB.Mlmap.dmerge(a2, ddiff, stepdiff)
  %{"spanning" => %{"o213" => :undefined, "v12" => %{"c3" => true}}}
  iex>  {metadiff, dmetadiff} = ADB.Mlmap.ddmerge(a2, metadiff, stepdiff, "undefined")
  iex>  metadiff == ADB.Mlmap.value_transform(ddiff, :undefined, "undefined")
  true
  iex>  ddiff2 = ADB.Mlmap.dupdate(a2, ddiff2, x, true)
  iex>  ddiff == ddiff2
  true
  iex>  {metadiff, :bump} == ADB.Mlmap.smerge(ometadiff, dmetadiff)
  true
  iex> ometadiff = metadiff
  iex>  {a, x} = ADB.Mlmap.supdate(a, ["spanning", "v12", "c3"], :undefined)
  iex>  diff = ADB.Mlmap.dupdate(ao, diff, x, :undefined)
  %{
    "spanning" => %{
      "c2" => :undefined,
      "o211" => :undefined,
      "o212" => :undefined,
      "o213" => :undefined,
      "v12" => %{"c2" => :undefined},
      "v21" => :undefined
    }
  }
  iex>  stepdiff = ADB.Mlmap.make_from_lst(x, :undefined)
  iex>  ddiff = ADB.Mlmap.dmerge(a2, ddiff, stepdiff)
  iex>  {metadiff, dmetadiff} = ADB.Mlmap.ddmerge(a2, metadiff, stepdiff, "undefined")
  iex>  metadiff == ADB.Mlmap.value_transform(ddiff, :undefined, "undefined")
  true
  iex>  ddiff2 = ADB.Mlmap.dupdate(a2, ddiff2, x, :undefined)
  iex>  ddiff == ddiff2
  true
  iex>  {metadiff, :bump} == ADB.Mlmap.smerge(ometadiff, dmetadiff)
  true
  iex> ometadiff = metadiff
  iex> {a, x} = ADB.Mlmap.supdate(a, ["spanning", "v12", "c1"], :undefined)
  iex> diff = ADB.Mlmap.dupdate(ao, diff, x, :undefined)
  iex>  stepdiff = ADB.Mlmap.make_from_lst(x, :undefined)
  iex>  ddiff = ADB.Mlmap.dmerge(a2, ddiff, stepdiff)
  iex>  {metadiff, dmetadiff} = ADB.Mlmap.ddmerge(a2, metadiff, stepdiff, "undefined")
  iex>  metadiff == ADB.Mlmap.value_transform(ddiff, :undefined, "undefined")
  true
  iex>  ddiff2 = ADB.Mlmap.dupdate(a2, ddiff2, x, :undefined)
  iex>  ddiff == ddiff2
  true
  iex>  {metadiff, :bump} == ADB.Mlmap.smerge(ometadiff, dmetadiff)
  true
  iex> diff
  %{
    "spanning" => %{
      "c2" => :undefined,
      "o211" => :undefined,
      "o212" => :undefined,
      "o213" => :undefined,
      "v12" => :undefined,
      "v21" => :undefined
    }
  }
  iex> {ao, diff2, a2, ddiff, a}
  {%{
   "spanning" => %{
     "c2" => %{"folder" => true}, "folder" => %{"show" => true}, "o111" => %{"v11" => true}, "o112" => %{"v11" => true},
     "o121" => %{"v12" => true}, "o122" => %{"v12" => true}, "o123" => %{"v12" => true},
     "o211" => %{"v21" => true}, "o212" => %{"v21" => true}, "o213" => %{"v21" => true},
     "v11" => %{"c1" => true}, "v12" => %{"c1" => true, "c2" => true}, "v21" => %{"c2" => true}
   }
  },
  %{"spanning" => %{"c2" => :undefined, "o211" => :undefined, "o212" => :undefined, "v12" => %{"c2" => :undefined}, "v21" => :undefined}},
  %{
   "spanning" => %{
     "folder" => %{"show" => true}, "o111" => %{"v11" => true}, "o112" => %{"v11" => true}, "o121" => %{"v12" => true},
     "o122" => %{"v12" => true}, "o123" => %{"v12" => true}, "o213" => %{"v21" => true}, "v11" => %{"c1" => true}, "v12" => %{"c1" => true}
   }
  },
  %{"spanning" => %{"o213" => :undefined, "v12" => :undefined}},
  %{
   "spanning" => %{
     "folder" => %{"show" => true}, "o111" => %{"v11" => true}, "o112" => %{"v11" => true},
     "o121" => %{"v12" => true}, "o122" => %{"v12" => true}, "o123" => %{"v12" => true}, "v11" => %{"c1" => true}
   }
  }}
  iex>  xdiff = ADB.Mlmap.dmerge(ao, diff2, ddiff)
  %{
    "spanning" => %{
      "c2" => :undefined,
      "o211" => :undefined,
      "o212" => :undefined,
      "o213" => :undefined,
      "v12" => :undefined,
      "v21" => :undefined
    }
  }
  iex>  xdiff == diff
  true



  @vsn `"#{@vsn}"`
  """

  require Logger
  require Util
  Util.arrow_assignment()

  @typedoc """
  Ez elvileg egy map of maps (a toplevel), es nem tartalmaz `:undefined`-et.
  """
  @type t :: Map.t()

  @typedoc """
  Olyan map, ami `:undefined`-et is tartalmaz, ami itt azt jelenti, hogy torles (metanyelvi ertek).
  Azaz ez a deltak tipusa. De ez nem fejezheto ki rendesen a tipusrendszerben.
  """
  @type t_undefined :: t

  @typedoc """
  Ez elvileg egy map of maps, de lehet `:undefined` is. Ez a toplevel.
  """
  @type t_diff :: t_undefined | :undefined

  @typedoc """
  A fanak az aga barmi lehet, ami ertek, de nem `:undefined`.
  Ez persze inkabb csak egy cimke.
  """
  @type t_node :: any
  @type t_node_undefined :: t_node

  @typedoc """
  A diffnek az aga barmi lehet, ami ertek, ideertve `:undefined`.
  Ez persze inkabb csak egy cimke.
  """
  @type t_node_diff :: t_node | :undefined

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

  # defmacro m_get_aux(s, lst, defa, unroll) do
  #   un = Macro.expand(unroll, __CALLER__)
  #   if un == 0 do
  #     quote do
  #       f_get_aux(unquote(s), unquote(lst), unquote(defa))
  #     end
  #   else
  #     un = un - 1
  #     quote location: :keep, bind_quoted: [lst: lst, s: s, defa: defa, un: un] do
  #       case lst do
  #         [] ->
  #           s
  #
  #         [key | rest] ->
  #           case Map.fetch(s, key) do
  #             {:ok, val} -> m_get_aux(val, rest, defa, un)
  #             :error -> defa
  #           end
  #       end
  #     end
  #   end
  # end
  #
  # def f_get_aux(s, lst, defa), do: m_get_aux(s, lst, defa, 1)
  #
  # @unroll 5
  #
  # def get_aux(s, lst, defa), do: m_get_aux(s, lst, defa, @unroll)

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
  @spec update(t, nonempty_list(any), any) :: t
  @spec update(t, [], a) :: a when a: var
  def update(s, lst, val) do
    case lst do
      [] ->
        val

      [key | rest] ->
        case Map.fetch(s, key) do
          {:ok, map} -> update_aux(map, rest, val)
          :error -> make_from_lst(rest, val)
        end >>> upd

        Map.put(s, key, upd)
    end
  end

  # @compile {:inline, update: 3}
  @spec update_aux(any, nonempty_list(any), any) :: t
  @spec update_aux(any, [], a) :: a when a: var
  def update_aux(s, lst, val) do
    case lst do
      [] ->
        val

      [key | rest] ->
        casemap s do
          case Map.fetch(s, key) do
            {:ok, map} -> update_aux(map, rest, val)
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

  @doc """
  Diff-et alkalmaz regebbi diffre, az eredeti fuggvenyeben.
  """
  @spec dupdate(t, t_diff, [any], any) :: t_diff
  def dupdate(orig, diff, lst, val) do
    case val do
      :undefined ->
        dupdate_aux_u(orig, diff, lst)

      _ ->
        dupdate_aux_val(orig, diff, lst, val)
    end
    |> case do
      :bump -> %{}
      x -> x
    end
  end

  @spec dupdate_aux_val(t_node, t_node_diff, [any], any) :: t_node_diff | :bump
  def dupdate_aux_val(orig, diff, lst, val) do
    case lst do
      [] ->
        if orig == val, do: :bump, else: val

      [key | rest] ->
        casemap diff do
          case Map.fetch(diff, key) do
            {:ok, map} ->
              # A diffben benne van a kulcs!
              casemap orig do
                case Map.fetch(orig, key) do
                  {:ok, omap} ->
                    case dupdate_aux_val(omap, map, rest, val) do
                      :bump ->
                        diff = Map.delete(diff, key)
                        if diff == %{}, do: :bump, else: diff

                      x ->
                        Map.put(diff, key, x)
                    end

                  :error ->
                    # Mivel az origban nem volt benne, a diffnek ez az aga nem tartalmazhat torlest,
                    # es mivel effektiv, ugyanolyan erteket sem, azaz az egyszeru update is jo.
                    Map.put(diff, key, update_aux(map, rest, val))
                end
              else
                # Egyszeru feluliras.
                Map.put(diff, key, update_aux(map, rest, val))
              end

            :error ->
              # A diffben nincs benne.
              # Mivel ez effektiv valtoztatas, ez az orighoz kepest is valtoztas kell legyen,
              # kulohben nem letezne.
              Map.put(diff, key, make_from_lst(rest, val))
          end
        else
          # Diff ertek vagy torles.
          # Itt toroltunk vagy felulirtunk egy erteket, vagy egy map-et.
          casemap orig do
            # Map volt, ezert azt ki kell robbantani.
            omap = Enum.map(orig, fn {k, _} -> {k, :undefined} end) |> Map.new()

            case Mlmap.get(orig, lst, :undefined) do
              :undefined ->
                # Nem volt benne az eredetiben.
                Map.put(omap, key, make_from_lst(rest, val))

              x ->
                # Ha ez ugyanaz, mint az eredeti, akkor egyszeruen torolni kell az agat,
                # kulonben beilleszteni.
                if val == x do
                  Map.delete(omap, key) >>> omap
                  if Map.size(omap) == 0, do: :bump, else: omap
                else
                  Map.put(omap, key, make_from_lst(rest, val))
                end
            end
          else
            # Erteket irtunk felul vagy toroltunk, ezert csak csere a map-ra.
            %{key => make_from_lst(rest, val)}
          end
        end
    end
  end

  @spec dupdate_aux_u(t_node, t_diff, [any]) :: t_diff | :bump
  def dupdate_aux_u(orig, diff, lst) do
    case lst do
      [] ->
        :undefined

      [key | rest] ->
        # Itt diff biztosan map, mivel a valtoztatas minimalis es effektiv,
        # ezert ha itt ertek lenne (vagy akar undefined), akkor az uj verzioban
        # nem mehetne tovabb a lista.
        case Map.fetch(diff, key) do
          {:ok, map} ->
            # Benne van. Itt meg kell nezni, hogy az eredetiben mi volt a helyzet,
            # mert ha nincs, akkor le kell vagni az agat.
            casemap orig do
              case Map.fetch(orig, key) do
                {:ok, omap} ->
                  # Az eredetiben is benne volt.
                  case dupdate_aux_u(omap, map, rest) do
                    :bump -> Map.delete(diff, key)
                    dd -> Map.put(diff, key, dd)
                  end

                :error ->
                  # Az eredetiben nem volt benne ez az ag, ezert le kell vagni.
                  Map.delete(diff, key)
              end >>> diff

              if Map.size(diff) == 0, do: :bump, else: diff
            else
              # Az eredetiben itt ertek volt.
              # A valtoztatas effektiv, ezert magaban a diffben kell valtoztatni.
              Map.put(diff, key, Mlmap.update_aux(map, rest, :undefined))
            end

          :error ->
            # Nincs benne, ezert benne kellett legyen az eredetiben.
            Map.put(diff, key, make_from_lst(rest, :undefined))
        end
    end
  end

  @spec dmerge_mmm(t, t_undefined, t_undefined) :: t_undefined | :bump
  def dmerge_mmm(orig, odiff, diff) do
    Enum.reduce(diff, odiff, fn {k, val}, odiff ->
      case Map.fetch(odiff, k) do
        {:ok, v} ->
          case Map.fetch(orig, k) do
            {:ok, ov} ->
              dmerge_aux(ov, v, val)

            :error ->
              # Eredetiben nem volt benne, es effektiv is,
              ucasemap val do
                casemap v do
                  # Merge
                  dmerge_diffdiff_aux(v, val)
                else
                  # Csere
                  val
                end
              else
                # Csere
                val
              catch
                # Torles, mivel az eredetiben nem volt benne, kiutheto a diff-bol.
                :bump
              end
          end

        :error ->
          case Map.fetch(orig, k) do
            {:ok, ov} ->
              # Itt nem kell robbantani, mert odiff-nek itt nem volt kulcsa, azaz orig ervenyesult eleve,
              # azaz itt egy meg mindig meglevo aggal kell egyesiteni, tehat nem kell visszahozni a regi kulcsokat.
              case dmerge_check_aux(ov, val) do
                :bump -> val
                # Ez elvileg nem lehet :undefined, mivel az azt jelentene, hogy diff-nek ez az aga felesleges,
                # Tehat hatastalan, holott diff elvileg optimalizalt.
                dd -> dd
              end

            :error ->
              val
          end
      end
      |> case do
        :bump -> Map.delete(odiff, k)
        to_put -> Map.put(odiff, k, to_put)
      end
    end) >>> odiff

    if Map.size(odiff) == 0, do: :bump, else: odiff
  end

  @doc """
  Legfelso szint, ahol orig biztosan map, es diffek vagy map-ok, vagy legfeljebb `:undefined`.
  """
  @spec dmerge(t, t_diff, t_diff) :: t_diff | :bump
  def dmerge(orig, odiff, diff) do
    casemap diff do
      # Map
      casemap(odiff) do
        # Map -> Map
        # (map) -> map -> map
        dmerge_mmm(orig, odiff, diff)
      else
        # Ertek -> map
        # odiff ertek, es biztosan elter, tehat a kerdes legfeljebb az, hogy mi volt orig itt.
        # (Map) -> ertek -> map
        # Itt egy erteket cserelunk vissza egy olyan helyen, ahol eredetileg map volt.
        # Magyaran diff-ben nem lehet mar :undefined, viszont egyes elemei (vagy akar az egesz)
        # megegyezhet orig-gal, azaz ossze kell vetni vele teljesen.
        # XXX
        diff = Map.keys(orig) |> Enum.map(fn x -> {x, :undefined} end) |> Map.new() |> Map.merge(diff)

        case dmerge_check(orig, diff) do
          :bump -> diff
          :undefined -> :bump
          dd -> dd
        end
      end
    else
      # Ertek == :undefined
      # Itt odiff nem lehet :undefined, mivel diff effektiv.
      # Viszont ezen a ponton orig letezik, tehat torolni kell.
      :undefined
    end
  end

  @spec dmerge_aux(t_node, t_node_diff, t_node_diff) :: t_node_diff | :bump
  def dmerge_aux(orig, odiff, diff) do
    ucasemap diff do
      # Map
      casemap(odiff) do
        # Map -> Map
        casemap orig do
          # (map) -> map -> map
          dmerge_mmm(orig, odiff, diff)
        else
          # {ertek} -> map -> map
          # Mivel itt orig ertek, nem szamit. Es mivel diff effektiv, ezert itt ossze kell mergelni odiffel.
          dmerge_diffdiff(odiff, diff)
        end
      else
        # Ertek -> map
        # odiff ertek, es biztosan elter, tehat a kerdes legfeljebb az, hogy mi volt orig itt.
        casemap orig do
          # (Map) -> ertek -> map
          # Itt egy erteket cserelunk vissza egy olyan helyen, ahol eredetileg map volt.
          # Magyaran diff-ben nem lehet mar :undefined, viszont egyes elemei (vagy akar az egesz)
          # megegyezhet orig-gal, azaz ossze kell vetni vele teljesen.
          # XXX
          diff = Map.keys(orig) |> Enum.map(fn x -> {x, :undefined} end) |> Map.new() |> Map.merge(diff)

          case dmerge_check(orig, diff) do
            :bump -> diff
            :undefined -> :bump
            dd -> dd
          end
        else
          # (Ertek) -> ertek -> map
          # Ertek volt mindket eredeti, biztosan cserelheto map-ra.
          # Itt egeszen biztosan nincs :undefined diff-ben, mivel effektiv es minimalis.
          diff
        end
      end
    else
      # Ertek
      # Itt odiff nem lehet egyenlo diff-fel, mivel az effektiv.
      # A kerdes az, hogy orig egyenlo-e.
      # Ha igen, akkor odiffnak ezt az agat torolni kell, kulonben felulirni.
      if orig == diff, do: :bump, else: diff
    catch
      # :undefined
      # Itt odiff nem lehet :undefined, mivel diff effektiv.
      # Viszont ezen a ponton orig letezik, tehat torolni kell.
      :undefined
    end
  end

  @spec dmerge_diffdiff(t_undefined, t_undefined) :: t_diff | :bump
  def dmerge_diffdiff(odiff, diff) do
    Enum.reduce(diff, odiff, fn {k, val}, odiff ->
      case Map.fetch(odiff, k) do
        {:ok, v} ->
          # Eredetiben nem volt benne, es effektiv is,
          ucasemap val do
            casemap v do
              # Merge
              case dmerge_diffdiff_aux(v, val) do
                :bump -> Map.delete(odiff, k)
                dd -> Map.put(odiff, k, dd)
              end
            else
              # Csere
              Map.put(odiff, k, val)
            end
          else
            # Csere
            Map.put(odiff, k, val)
          catch
            # Torles
            Map.delete(odiff, k)
          end

        :error ->
          # Az odiff-ben nem volt benne, de effektiv, es nem lehet torles, tehat insert
          Map.put(odiff, k, val)
      end
    end) >>> odiff

    if map_size(odiff) == 0, do: :bump, else: odiff
  end

  @spec dmerge_diffdiff_aux(t_node_diff, t_node_diff) :: t_node_diff | :bump
  def dmerge_diffdiff_aux(odiff, diff) do
    ucasemap diff do
      # Map
      casemap(odiff) do
        # Map -> Map
        # {ertek} -> map -> map
        # Mivel itt orig ertek, nem szamit. Es mivel diff effektiv, ezert itt ossze kell mergelni odiffel.
        dmerge_diffdiff(odiff, diff)
      else
        # Ertek -> map
        # odiff ertek, es biztosan elter. Itt diff biztosan csak insert.
        diff
      end
    else
      # Ertek
      # Itt odiff nem lehet egyenlo diff-fel, mivel az effektiv.
      diff
    catch
      # Torles
      # Mivel itt nincs orig, ezert ha torlunk, a diff-bol is torolni kell.
      :bump
    end
  end

  @spec dmerge_check(t, t_undefined) :: :bump | t_diff
  def dmerge_check(orig, diff) do
    Enum.reduce(diff, {diff, false}, fn {k, val}, {diff, chg} ->
      case Map.fetch(orig, k) do
        {:ok, v} ->
          case dmerge_check_aux(v, val) do
            :undefined -> {Map.delete(diff, k), true}
            :bump -> {diff, chg}
            dd -> {Map.put(diff, k, dd), true}
          end

        :error ->
          # Itt akarmi van diff-ben, nekunk az jo, es idevalo.
          {diff, chg}
      end
    end) >>> {dd, chg}

    if chg, do: if(Map.size(dd) == 0, do: :undefined, else: dd), else: :bump
  end

  @spec dmerge_check_aux(t_node, t_node_diff) :: :bump | t_node_diff
  def dmerge_check_aux(orig, diff) do
    ucasemap diff do
      # Map
      casemap orig do
        # Map -> map
        dmerge_check(orig, diff)
      else
        # ertek -> map, biztosan effektiv
        :bump
      end
    else
      # Ertek
      casemap orig do
        # Map -> ertek, biztosan effektiv
        :bump
      else
        # ertek -> ertek
        if diff == orig, do: :undefined, else: :bump
      end
    catch
      :bump
    end
  end

  @spec dmerdate(t_node, t_node_diff, [any], any) :: t_node_diff | :bump
  def dmerdate(orig, diff, lst, val) do
    case lst do
      [] ->
        dmerge_aux(orig, diff, val)

      [key | rest] ->
        casemap diff do
          case Map.fetch(diff, key) do
            {:ok, map} ->
              # A diffben benne van a kulcs!
              casemap orig do
                case Map.fetch(orig, key) do
                  {:ok, omap} ->
                    case dmerdate(omap, map, rest, val) do
                      :bump ->
                        diff = Map.delete(diff, key)
                        if diff == %{}, do: :bump, else: diff

                      x ->
                        Map.put(diff, key, x)
                    end

                  :error ->
                    # Mivel az origban nem volt benne, a diffnek ez az aga nem tartalmazhat torlest,
                    # es mivel effektiv, ugyanolyan erteket sem, azaz az egyszeru update is jo.
                    Map.put(diff, key, update_aux(map, rest, val))
                end
              else
                # Egyszeru feluliras.
                Map.put(diff, key, update_aux(map, rest, val))
              end

            :error ->
              # A diffben nincs benne.
              # Mivel ez effektiv valtoztatas, ez az orighoz kepest is valtoztas kell legyen, kulohben nem letezne.
              # Viszont maga a valtoztatas mar optimalis, mivel egyszer mar ossze volt vetve origgal
              # (mivel az uj adatszerkezetnek ez a resze meg kell egyezzen origgal, hiszen diffnek nem resze)
              # Ezert aztan egy egyszeru insert meg kell tegye.
              Map.put(diff, key, make_from_lst(rest, val))
          end
        else
          # Diff ertek vagy torles.
          # Itt toroltunk vagy felulirtunk egy erteket, vagy egy map-et.
          casemap orig do
            # Map volt, ezert azt ki kell robbantani.
            omap = Enum.map(orig, fn {k, _} -> {k, :undefined} end) |> Map.new()

            case Mlmap.get(orig, lst, :undefined) do
              :undefined ->
                # Nem volt benne az eredetiben.
                Map.put(omap, key, make_from_lst(rest, val))

              x ->
                # Ha ez ugyanaz, mint az eredeti, akkor egyszeruen torolni kell az agat,
                # kulonben beilleszteni.
                if val == x do
                  Map.delete(omap, key) >>> omap
                  if Map.size(omap) == 0, do: :bump, else: omap
                else
                  Map.put(omap, key, make_from_lst(rest, val))
                end
            end
          else
            # Erteket irtunk felul vagy toroltunk, ezert csak csere a map-ra.
            %{key => make_from_lst(rest, val)}
          end
        end
    end
  end

  ######          ##     ## ########  ########          ########  #### ######## ######## ########  #### ######## ########          ######
  ##              ##     ## ##     ## ##     ##         ##     ##  ##  ##       ##       ##     ##  ##  ##       ##                    ##
  ##              ##     ## ##     ## ##     ##         ##     ##  ##  ##       ##       ##     ##  ##  ##       ##                    ##
  ##              ##     ## ########  ##     ##         ##     ##  ##  ######   ######   ##     ##  ##  ######   ######                ##
  ##              ##     ## ##        ##     ##         ##     ##  ##  ##       ##       ##     ##  ##  ##       ##                    ##
  ##              ##     ## ##        ##     ##         ##     ##  ##  ##       ##       ##     ##  ##  ##       ##                    ##
  ######           #######  ##        ########  ####### ########  #### ##       ##       ########  #### ##       ##                ######

  @spec ddmerge_mmm(t, t, t_undefined, any) :: {t_undefined, t_diff}
  def ddmerge_mmm(orig, odiff, diff, meta) do
    Enum.reduce(diff, {odiff, %{}}, fn {k, val}, {odiff, ndiff} ->
      case Map.fetch(odiff, k) do
        {:ok, v} ->
          case Map.fetch(orig, k) do
            {:ok, ov} ->
              ddmerge_aux(ov, v, val, meta)

            :error ->
              # Eredetiben nem volt benne, es effektiv is,
              ucasemap val do
                casemap v do
                  # Merge
                  case dmerge_diffdiff_aux(v, val) do
                    :bump -> :bump
                    dd -> {dd, dd}
                  end
                else
                  # Csere
                  {val, val}
                end
              else
                # Csere
                {val, val}
              catch
                # Torles, mivel az eredetiben nem volt benne, kiutheto a diff-bol.
                :bump
              end
          end

        :error ->
          case Map.fetch(orig, k) do
            {:ok, ov} ->
              # Itt nem kell robbantani, mert odiff-nek itt nem volt kulcsa, azaz orig ervenyesult eleve,
              # azaz itt egy meg mindig meglevo aggal kell egyesiteni, tehat nem kell visszahozni a regi kulcsokat.
              case ddmerge_check_aux(ov, val, meta) do
                :bump -> {val, val}
                # Ez elvileg nem lehet :undefined, mivel az azt jelentene, hogy diff-nek ez az aga felesleges,
                # Tehat hatastalan, holott diff elvileg optimalizalt.
                dd -> {dd, dd}
              end

            :error ->
              {val, val}
          end
      end
      |> case do
        :bump -> {Map.delete(odiff, k), Map.put(ndiff, k, :undefined)}
        {a, b} -> {Map.put(odiff, k, a), Map.put(ndiff, k, b)}
      end
    end) >>> {odiff, ndiff}

    if Map.size(odiff) == 0, do: :bump, else: {odiff, ndiff}
  end

  @doc """
  Legfelso szint, ahol orig biztosan map, es diffek vagy map-ok, vagy legfeljebb `:undefined`.
  """
  @spec ddmerge(t, t, t_diff, any) :: {t, t_diff} | :bump
  def ddmerge(orig, odiff, diff, meta) do
    casemap diff do
      # Map
      casemap(odiff) do
        # Map -> Map
        # (map) -> map -> map
        ddmerge_mmm(orig, odiff, diff, meta)
      else
        # Ertek -> map
        # odiff ertek, es biztosan elter, tehat a kerdes legfeljebb az, hogy mi volt orig itt.
        # (Map) -> ertek -> map
        # Itt egy erteket cserelunk vissza egy olyan helyen, ahol eredetileg map volt.
        # Magyaran diff-ben nem lehet mar :undefined, viszont egyes elemei (vagy akar az egesz)
        # megegyezhet orig-gal, azaz ossze kell vetni vele teljesen.
        diff = Map.keys(orig) |> Enum.map(fn x -> {x, :undefined} end) |> Map.new() |> Map.merge(diff)

        case ddmerge_check(orig, diff, meta) do
          :bump -> {diff, diff}
          :undefined -> :bump
          dd -> {dd, dd}
        end
      end
    else
      # Ertek == :undefined
      # Itt odiff nem lehet :undefined, mivel diff effektiv.
      # Viszont ezen a ponton orig letezik, tehat torolni kell.
      {meta, meta}
    end
  end

  @spec ddmerge_aux(t_node, t_node, t_node_diff, any) :: {t_node, t_node_diff} | :bump
  def ddmerge_aux(orig, odiff, diff, meta) do
    ucasemap diff do
      # Map
      casemap(odiff) do
        # Map -> Map
        casemap orig do
          # (map) -> map -> map
          ddmerge_mmm(orig, odiff, diff, meta)
        else
          # {ertek} -> map -> map
          # Mivel itt orig ertek, nem szamit. Es mivel diff effektiv, ezert itt ossze kell mergelni odiffel.
          case dmerge_diffdiff(odiff, diff) do
            :bump -> :bump
            dd -> {dd, dd}
          end
        end
      else
        # Ertek -> map
        # odiff ertek, es biztosan elter, tehat a kerdes legfeljebb az, hogy mi volt orig itt.
        casemap orig do
          # (Map) -> ertek -> map
          # Itt egy erteket cserelunk vissza egy olyan helyen, ahol eredetileg map volt.
          # Magyaran diff-ben nem lehet mar :undefined, viszont egyes elemei (vagy akar az egesz)
          # megegyezhet orig-gal, azaz ossze kell vetni vele teljesen.
          diff = Map.keys(orig) |> Enum.map(fn x -> {x, :undefined} end) |> Map.new() |> Map.merge(diff)

          case ddmerge_check(orig, diff, meta) do
            :bump -> {diff, diff}
            :undefined -> :bump
            dd -> {dd, dd}
          end
        else
          # (Ertek) -> ertek -> map
          # Ertek volt mindket eredeti, biztosan cserelheto map-ra.
          # Itt egeszen biztosan nincs :undefined diff-ben, mivel effektiv es minimalis.
          {diff, diff}
        end
      end
    else
      # Ertek
      # Itt odiff nem lehet egyenlo diff-fel, mivel az effektiv.
      # A kerdes az, hogy orig egyenlo-e.
      # Ha igen, akkor odiffnak ezt az agat torolni kell, kulonben felulirni.
      if orig == diff, do: :bump, else: {diff, diff}
    catch
      # :undefined
      # Itt odiff nem lehet :undefined, mivel diff effektiv.
      # Viszont ezen a ponton orig letezik, tehat torolni kell.
      {meta, meta}
    end
  end

  @spec ddmerge_check(t, t_undefined, any) :: :bump | t_diff
  def ddmerge_check(orig, diff, meta) do
    Enum.reduce(diff, {diff, false}, fn {k, val}, {diff, chg} ->
      case Map.fetch(orig, k) do
        {:ok, v} ->
          case ddmerge_check_aux(v, val, meta) do
            :undefined -> {Map.delete(diff, k), true}
            :bump -> {diff, chg}
            dd -> {Map.put(diff, k, dd), true}
          end

        :error ->
          # Itt akarmi van diff-ben, nekunk az jo, es idevalo.
          # Ez nem lehet :undefined, mert orig-ban itt nincs semmi, es az ujban sem.
          # Azaz ez CSAK insert.
          {diff, chg}
      end
    end) >>> {dd, chg}

    if chg, do: if(Map.size(dd) == 0, do: :undefined, else: dd), else: :bump
  end

  @spec ddmerge_check_aux(t_node, t_node_diff, any) :: :bump | t_node_diff
  def ddmerge_check_aux(orig, diff, meta) do
    ucasemap diff do
      # Map
      casemap orig do
        # Map -> map
        ddmerge_check(orig, diff, meta)
      else
        # ertek -> map, biztosan effektiv, csak insert
        :bump
      end
    else
      # Ertek
      casemap orig do
        # Map -> ertek, biztosan effektiv
        :bump
      else
        # ertek -> ertek
        if diff == orig, do: :undefined, else: :bump
      end
    catch
      # :undefined
      meta
    end
  end

  @spec ddmerdate(t_node, t_node, [any], t_node_diff, any) :: {t_node, [any], t_node_diff} | :bump
  def ddmerdate(orig, diff, lst, val, meta) do
    case lst do
      [] ->
        case ddmerge_aux(orig, diff, val, meta) do
          :bump -> :bump
          {ss, dd} -> {ss, [], dd}
        end

      [key | rest] ->
        casemap diff do
          case Map.fetch(diff, key) do
            {:ok, map} ->
              # A diffben benne van a kulcs!
              casemap orig do
                case Map.fetch(orig, key) do
                  {:ok, omap} ->
                    case ddmerdate(omap, map, rest, val, meta) do
                      :bump ->
                        diff = Map.delete(diff, key)

                        if diff == %{} do
                          :bump
                        else
                          {diff, [key], :undefined}
                        end

                      {ss, ll, dd} ->
                        {Map.put(diff, key, ss), [key | ll], dd}
                    end

                  :error ->
                    # Mivel az origban nem volt benne, a diffnek ez az aga nem tartalmazhat torlest,
                    # es mivel effektiv, ugyanolyan erteket sem, azaz az egyszeru update is jo.
                    a = update_aux(map, rest, val)
                    {Map.put(diff, key, a), [key], a}
                end
              else
                # Egyszeru feluliras.
                a = update_aux(map, rest, val)
                {Map.put(diff, key, a), [key], a}
              end

            :error ->
              # A diffben nincs benne.
              # Mivel ez effektiv valtoztatas, ez az orighoz kepest is valtoztas kell legyen, kulohben nem letezne.
              # Viszont maga a valtoztatas mar optimalis, mivel egyszer mar ossze volt vetve origgal
              # (mivel az uj adatszerkezetnek ez a resze meg kell egyezzen origgal, hiszen diffnek nem resze)
              # Ezert aztan egy egyszeru insert meg kell tegye.
              a = make_from_lst(rest, val)
              {Map.put(diff, key, a), [key], a}
          end
        else
          # Diff ertek vagy torles.
          # Itt toroltunk vagy felulirtunk egy erteket, vagy egy map-et.
          casemap orig do
            # Map volt, ezert azt ki kell robbantani.
            omap = Enum.map(orig, fn {k, _} -> {k, meta} end) |> Map.new()

            case Mlmap.get(orig, lst, :undefined) do
              :undefined ->
                # Nem volt benne az eredetiben.
                Map.put(omap, key, make_from_lst(rest, val))

              x ->
                # Ha ez ugyanaz, mint az eredeti, akkor egyszeruen torolni kell az agat,
                # kulonben beilleszteni.
                if val == x do
                  Map.delete(omap, key) >>> omap
                  if Map.size(omap) == 0, do: :bump, else: omap
                else
                  Map.put(omap, key, make_from_lst(rest, val))
                end
            end
          else
            # Erteket irtunk felul vagy toroltunk, ezert csak csere a map-ra.
            %{key => make_from_lst(rest, val)}
          end
          |> case do
            :bump -> :bump
            a -> {a, [], a}
          end
        end
    end
  end

  ######          ##     ## ########  ########          ##     ## ######## ########    ###             ######
  ##              ##     ## ##     ## ##     ##         ###   ### ##          ##      ## ##                ##
  ##              ##     ## ##     ## ##     ##         #### #### ##          ##     ##   ##               ##
  ##              ##     ## ########  ##     ##         ## ### ## ######      ##    ##     ##              ##
  ##              ##     ## ##        ##     ##         ##     ## ##          ##    #########              ##
  ##              ##     ## ##        ##     ##         ##     ## ##          ##    ##     ##              ##
  ######           #######  ##        ########  ####### ##     ## ########    ##    ##     ##          ######

  # Itt normal adatszerkezetekre alkalmazunk diff-eket, azaz a diff-ben metanyelvi ertelme van az `:undefined`-nek.

  @doc """
  Egy diff alkalmazasa utani allapot, kiszuri a felesleges dolgokat.
  """
  # @compile {:inline, normalize: 1}
  @spec snormalize(t_diff) :: :bump | t_diff
  def snormalize(s) do
    case s do
      %{} when map_size(s) == 0 ->
        :undefined

      :undefined ->
        :undefined

      _ ->
        Enum.reduce(s, {[], []}, fn {k, v}, {droplist, chglist} = res ->
          ucasemap v do
            if Map.size(v) == 0 do
              {[k | droplist], chglist}
            else
              case snormalize(v) do
                :undefined -> {[k | droplist], chglist}
                :bump -> res
                nv -> {droplist, [{k, nv} | chglist]}
              end
            end
          else
            res
          catch
            {[k | droplist], chglist}
          end
        end)
        |> case do
          {[], []} ->
            :bump

          {[], chglist} ->
            Map.merge(s, Map.new(chglist))

          {droplist, []} ->
            s = Map.drop(s, droplist)
            if Map.size(s) == 0, do: :undefined, else: s

          {droplist, chglist} ->
            s = Map.drop(s, droplist)
            chgmap = Map.new(chglist)
            if Map.size(s) == 0, do: chgmap, else: Map.merge(s, chgmap)
        end
    end
  end

  @doc """
  Toplevel, ahol legalabb `s` map, es `diff` legfeljebb `:undefined`.

  Visszajon:
  - `:bump`, akkor `diff == %{}`.
  - `:undefined`, akkor `diff == :undefined`.
  - `{s, diff}`, akkor `s` transzformalt, `diff` optimalizalt.
  """
  @spec smerge(t, t_diff) :: :bump | {t | :undefined, t_diff | :bump}
  def smerge(s, diff) do
    casemap diff do
      # Map -> map
      smerge_aux_mapmap(s, diff)
    else
      # Map -> :undefined
      {:undefined, :bump}
    end
  end

  @doc """
  Merge, ahol a masodik egy diff. Semmilyen megkotes nincs ezen kivul a parameterekre.

  Visszajon:
  - `:bump`, akkor `diff == %{}`.
  - `:undefined`, akkor `diff == :undefined`.
  - `{s, diff}`, akkor `s` transzformalt, `diff` optimalizalt.
  """
  # @compile {:inline, smerge_aux: 2}
  @spec smerge_aux(t_node, t_node_diff) :: :bump | {t_node | :undefined, t_node_diff | :bump}
  def smerge_aux(s, diff) do
    casemap s do
      # Map-csere
      smerge_aux_map(s, diff)
    else
      # Ertek-csere
      smerge_aux_val(s, diff)
    end
  end

  @doc """
  Mindket parameter biztosan map (egyebkent ez a tipikus eset).
  """
  @spec smerge_aux_mapmap(t, t_undefined) :: :bump | {t | :undefined, t_diff | :bump}
  def smerge_aux_mapmap(s, diff) do
    Enum.reduce(diff, {s, false, diff, false}, fn {k, v}, {s, schg, diff, dchg} ->
      case Map.fetch(s, k) do
        {:ok, v2} ->
          case smerge_aux(v2, v) do
            :bump ->
              {s, schg, Map.delete(diff, k), true}

            {ss, dd} ->
              s = if(ss == :undefined, do: Map.delete(s, k), else: Map.put(s, k, ss))

              case dd do
                :bump -> {s, true, diff, dchg}
                _ -> {s, true, Map.put(diff, k, :undefined), true}
              end
          end

        :error ->
          ucasemap v do
            case snormalize(v) do
              :undefined -> {s, schg, Map.delete(diff, k), true}
              :bump -> {Map.put(s, k, v), true, diff, dchg}
              nv -> {Map.put(s, k, nv), true, Map.put(diff, k, nv), true}
            end
          else
            {Map.put(s, k, v), true, diff, dchg}
          catch
            {s, schg, Map.delete(diff, k), true}
          end
      end
    end) >>> {s, schg, diff, dchg}

    # Map -> Map eredmenye
    Util.wife :bump, schg do
      Util.wife {:undefined, :undefined}, Map.size(s) != 0 do
        Util.wife :bump, Map.size(diff) != 0 do
          {s, if(dchg, do: diff, else: :bump)}
        end
      end
    end
  end

  @doc """
  Itt `s` biztosan nem map, de ezt a tipusrendszer nem tudja kifejezni.
  """
  @spec smerge_aux_val(t_node, t_node_diff) :: :bump | {t_node | :undefined, t_node_diff | :bump}
  def smerge_aux_val(s, diff) do
    ucasemap diff do
      # Ertek -> map
      case snormalize(diff) do
        :undefined -> {:undefined, :undefined}
        :bump -> {diff, :bump}
        ndiff -> {ndiff, ndiff}
      end
    else
      # Ertek -> ertek
      if diff == s, do: :bump, else: {diff, :bump}
    catch
      {:undefined, :bump}
    end
  end

  @doc """
  Itt `s` map, `diff` pedig barmi lehet.
  Egyebkent lenyegeben ugyanaz a kod, mint `smerge`,
  de a tisztasag kedveert kiemeltuk kulon.
  """
  @spec smerge_aux_map(t, t_node_diff) :: :bump | {t_node | :undefined, t_node_diff | :bump}
  def smerge_aux_map(s, diff) do
    casemap diff do
      # Map -> map
      smerge_aux_mapmap(s, diff)
    else
      # Map -> ertek
      {diff, :bump}
    end
  end

  @doc """
  Top-level, ahol a parameterek "jok".
  """
  @spec smerdate(t, [any], t_diff) :: :bump | {t | :undefined, [any], t_diff | :bump}
  def smerdate(s, lst, val) do
    case lst do
      [] ->
        case smerge(s, val) do
          :bump -> :bump
          {ss, dd} -> {ss, [], dd}
        end

      [key | rest] ->
        case Map.fetch(s, key) do
          {:ok, map} ->
            case smerdate_aux(map, rest, val) do
              :bump ->
                :bump

              {ss, ll, dd} ->
                if ss == :undefined do
                  {Map.delete(s, key), [key], dd}
                else
                  {Map.put(s, key, ss), [key | ll], dd}
                end
            end

          :error ->
            case n_smake_from_lst(rest, val) do
              :undefined -> :bump
              {ss, ll, dd} -> {Map.put(s, key, ss), [key | ll], dd}
            end
        end

        # case lst
    end
  end

  @spec smerdate_map(t, [any], t_node_diff) :: :bump | {t | :undefined, [any], t_node_diff | :bump}
  def smerdate_map(s, lst, val) do
    case lst do
      [] ->
        case smerge_aux_map(s, val) do
          :bump -> :bump
          {ss, dd} -> {ss, [], dd}
        end

      [key | rest] ->
        case Map.fetch(s, key) do
          {:ok, map} ->
            case smerdate_aux(map, rest, val) do
              :bump ->
                :bump

              {ss, ll, dd} ->
                if ss == :undefined do
                  {Map.delete(s, key), [key], dd}
                else
                  {Map.put(s, key, ss), [key | ll], dd}
                end
            end

          :error ->
            case n_smake_from_lst(rest, val) do
              :undefined -> :bump
              {ss, ll, dd} -> {Map.put(s, key, ss), [key | ll], dd}
            end
        end

        # case lst
    end
  end

  # @compile {:inline, smerdate: 3}
  @spec smerdate_aux(t_node, [any], t_node_diff) :: :bump | {t_node | :undefined, [any], t_node_diff | :bump}
  def smerdate_aux(s, lst, val) do
    casemap s do
      smerdate_map(s, lst, val)
    else
      case lst do
        [] ->
          case smerge_aux_val(s, val) do
            :bump -> :bump
            {ss, dd} -> {ss, [], dd}
          end

        _ ->
          n_smake_from_lst(lst, val)
      end
    end
  end

  @doc """
  Olyan esetben hasznalhato, amikor `val` mar meg van ragva, es biztosan effektiv.
  """
  # @compile {:inline, smerdate_n: 2}
  @spec smerdate_n(t, [any], t_diff) :: {t | :undefined, [any]}
  def smerdate_n(s, lst, val) do
    case lst do
      [] ->
        case smerge(s, val) do
          :bump ->
            # Itt ilyen eset elvileg NEM LEHET!
            Logger.warn("bump, s: #{inspect(s)}, val: #{inspect(val)}")
            {s, []}

          {ss, _dd} ->
            {ss, []}
        end

      [key | rest] ->
        case Map.fetch(s, key) do
          {:ok, map} ->
            smerdate_n_aux(map, rest, val) >>> {ss, ll}

            if ss == :undefined do
              {Map.delete(s, key), [key]}
            else
              {Map.put(s, key, ss), [key | ll]}
            end

          :error ->
            {Map.put(s, key, smake_from_lst(rest, val)), lst}
        end
    end
  end

  @spec smerdate_n_map(t, [any], t_node_diff) :: {t | :undefined, [any]}
  def smerdate_n_map(s, lst, val) do
    case lst do
      [] ->
        case smerge_aux_map(s, val) do
          :bump ->
            # Itt ilyen eset elvileg NEM LEHET!
            Logger.warn("bump, s: #{inspect(s)}, val: #{inspect(val)}")
            {s, []}

          {ss, _dd} ->
            {ss, []}
        end

      [key | rest] ->
        case Map.fetch(s, key) do
          {:ok, map} ->
            smerdate_n_aux(map, rest, val) >>> {ss, ll}

            if ss == :undefined do
              {Map.delete(s, key), [key]}
            else
              {Map.put(s, key, ss), [key | ll]}
            end

          :error ->
            {Map.put(s, key, smake_from_lst(rest, val)), lst}
        end
    end
  end

  @spec smerdate_n_aux(t_node, [any], t_node_diff) :: {t_node | :undefined, [any]}
  def smerdate_n_aux(s, lst, val) do
    case lst do
      [] ->
        case smerge_aux(s, val) do
          :bump ->
            # Itt ilyen eset elvileg NEM LEHET!
            Logger.warn("bump, s: #{inspect(s)}, val: #{inspect(val)}")
            {s, []}

          {ss, _dd} ->
            {ss, []}
        end

      [key | rest] ->
        casemap s do
          case Map.fetch(s, key) do
            {:ok, map} ->
              smerdate_n_aux(map, rest, val) >>> {ss, ll}

              if ss == :undefined do
                {Map.delete(s, key), [key]}
              else
                {Map.put(s, key, ss), [key | ll]}
              end

            :error ->
              {Map.put(s, key, smake_from_lst(rest, val)), lst}
          end
        else
          {smake_from_lst(lst, val), lst}
        end

        # case lst
    end

    # def smerdate
  end

  @doc """
  Toplevel, ahol `s` biztosan map.
  """
  # @compile {:inline, supdate: 3}
  @spec supdate(t, [any], any) :: {t, [any]} | :bump | :undefined
  def supdate(s, lst, val) do
    case val do
      :undefined ->
        supdate_aux_m_u(s, lst)

      _ ->
        case supdate_aux_m_val(s, lst, val) do
          :bump -> :bump
          upd -> {upd, lst}
        end
    end
  end

  # @compile {:inline, supdate_aux: 3}
  @spec supdate_aux_val(any, nonempty_list(any), any) :: t | :bump
  @spec supdate_aux_val(any, [], a) :: :bump | a when a: var
  def supdate_aux_val(s, lst, val) do
    case lst do
      [] ->
        if val == s, do: :bump, else: val

      [key | rest] ->
        casemap s do
          case Map.fetch(s, key) do
            {:ok, map} ->
              case supdate_aux_val(map, rest, val) do
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

  @spec supdate_aux_m_val(t, nonempty_list(any), any) :: :bump | t
  @spec supdate_aux_m_val(t, [], a) :: :bump | a when a: var
  def supdate_aux_m_val(s, lst, val) do
    case lst do
      [] ->
        if val == s, do: :bump, else: val

      [key | rest] ->
        case Map.fetch(s, key) do
          {:ok, map} ->
            case supdate_aux_val(map, rest, val) do
              :bump -> :bump
              upd -> Map.put(s, key, upd)
            end

          :error ->
            Map.put(s, key, smake_from_lst(rest, val))
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

  @spec supdate_aux_m_u(t, nonempty_list(any)) :: {t, [any]} | :undefined | :bump
  @spec supdate_aux_m_u(t, []) :: :undefined
  def supdate_aux_m_u(s, lst) do
    case lst do
      [] ->
        # Itt a torlese a levelnek.
        :undefined

      [key | rest] ->
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
    end
  end

  # @compile {:inline, n_smake_from_lst: 2}
  @spec n_smake_from_lst([any], t_diff) :: {t_node, [any], t_node_diff | :bump} | :undefined
  def n_smake_from_lst(lst, val) do
    case snormalize(val) do
      :undefined -> :undefined
      :bump -> {smake_from_lst(lst, val), lst, :bump}
      nval -> {smake_from_lst(lst, nval), lst, nval}
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

  @doc """
  Csak teszteleshez! Kicserel minden `from`-ot `to`-ra, ahol `from` csak ertek (level) lehet.
  """
  @spec value_transform(t, any, any) :: t
  def value_transform(s, from, to) do
    Enum.map(s, fn {k, v} ->
      casemap v do
        {k, value_transform(v, from, to)}
      else
        if v == from, do: {k, to}, else: {k, v}
      end
    end)
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
