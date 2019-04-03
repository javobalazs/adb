alias ADB.Stage
alias ADB.Mlmap
alias ADB.Store
alias ADB.Rule

defmodule Store do
  require Util
  require Logger

  ######          ######## ##    ## ########  ########          ######
  ##                 ##     ##  ##  ##     ## ##                    ##
  ##                 ##      ####   ##     ## ##                    ##
  ##                 ##       ##    ########  ######                ##
  ##                 ##       ##    ##        ##                    ##
  ##                 ##       ##    ##        ##                    ##
  ######             ##       ##    ##        ########          ######

  defstruct diffs1: %{},
            diffs2: %{},
            diffs12: %{},
            origs1: %{},
            origs2: %{},
            origs12: %{},
            last_mod1: %{},
            last_mod2: %{},
            last_mod12: %{},
            rules_ver: %{},
            ver_num: %{1 => 1},
            rules: %{},
            last: 1,
            first: %{},
            internal1: %{},
            internal2: %{},
            internal12: %{},
            pid: nil,
            msgqueue: [],
            qlen: 0

  @type t :: %__MODULE__{
          diffs1: %{Integer.t() => Map.t()},
          diffs2: %{Integer.t() => Map.t()},
          diffs12: %{Integer.t() => Map.t()},
          origs1: %{Integer.t() => Map.t()},
          origs2: %{Integer.t() => Map.t()},
          origs12: %{Integer.t() => Map.t()},
          last_mod1: %{Mulmap.iden() => Integer.t()},
          last_mod2: %{Mulmap.iden() => Integer.t()},
          last_mod12: %{{Mulmap.iden(), Mulmap.iden()} => Integer.t()},
          rules_ver: %{Mulmap.iden() => Integer.t()},
          ver_num: %{Integer.t() => Integer.t()},
          rules: %{Mulmap.iden() => Rule.t()},
          last: Integer.t(),
          first: %{Rule.burst() => Integer.t()},
          internal1: Map.t(),
          internal2: Map.t(),
          internal12: Map.t(),
          pid: String.t(),
          msgqueue: [{Mulmap.iden(), Mulmap.key(), Mulmap.scalar()}],
          qlen: Integer.t()
        }

  @spec constructor(String.t()) :: t
  def constructor(pid), do: %__MODULE__{pid: pid}

  ######           ######  #### ##    ##  ######   ##       ########          ######
  ##              ##    ##  ##  ###   ## ##    ##  ##       ##                    ##
  ##              ##        ##  ####  ## ##        ##       ##                    ##
  ##               ######   ##  ## ## ## ##   #### ##       ######                ##
  ##                    ##  ##  ##  #### ##    ##  ##       ##                    ##
  ##              ##    ##  ##  ##   ### ##    ##  ##       ##                    ##
  ######           ######  #### ##    ##  ######   ######## ########          ######

  @spec execute(t, String.t()) :: t
  def execute(s, name) do
    # Cache.
    rule = Map.get(s.rules, name, nil)

    # Letezik-e egyaltalan?
    Util.wife s, rule != nil do
      rule_time = Map.get(s.rules_ver, name, 0)
      last = s.last

      Util.wife s, last != rule_time do
        # Vonatkozik-e ra a dolog?
        last_mod_check = s.last_mod1 |> Map.take(rule.observe1_eff) |> Enum.reduce_while(false, fn {_k, ver}, _acc -> if(ver > rule_time, do: {:halt, true}, else: {:cont, false}) end)

        last_mod_check =
          Util.wife true, !last_mod_check do
            last_mod_check = s.last_mod2 |> Map.take(rule.observe2_eff) |> Enum.reduce_while(false, fn {_k, ver}, _acc -> if(ver > rule_time, do: {:halt, true}, else: {:cont, false}) end)

            Util.wife true, !last_mod_check do
              s.last_mod12 |> Map.take(rule.observe12_eff) |> Enum.reduce_while(false, fn {_k, ver}, _acc -> if(ver > rule_time, do: {:halt, true}, else: {:cont, false}) end)
            end
          end

        # Volt-e egyaltalan valtozas?
        if last_mod_check do
          execute_step(s, name, rule_time, rule.binding, rule.function, true)
        else
          ver_num_bump(s, last, name, rule_time)
        end
      end
    end

    # def execute
  end

  @spec execute_step(t, Mulmap.iden(), Integer.t(), Rule.binding(), Rule.functionx(), Boolean.t()) :: t
  def execute_step(s, name, rule_time, binding, function, real) do
    last = s.last
    # Valtozok kiszedese.
    internal1 = s.internal1
    internal2 = s.internal2
    internal12 = s.internal12
    diffs1 = s.diffs1
    diffs2 = s.diffs2
    diffs12 = s.diffs12
    origs1 = s.origs1
    origs2 = s.origs2
    origs12 = s.origs12

    # Diffek kiszedese, atmeneti stage letrehozasa.
    {diff1, diff2, diff12, orig1, orig2, orig12} =
      if real do
        if rule_time == 0 do
          {internal1, internal2, internal12, %{}, %{}, %{}}
        else
          {diffs1 |> Map.get(rule_time), diffs2 |> Map.get(rule_time), diffs12 |> Map.get(rule_time), origs1 |> Map.get(rule_time), origs2 |> Map.get(rule_time), origs12 |> Map.get(rule_time)}
        end
      else
        {%{}, %{}, %{}, internal1, internal2, internal12}
      end

    # Logger.warn(" store: #{name} =======store==> #{inspect s, pretty: true} ")

    # Elokeszites...
    stage = Stage.constructor(orig1, orig2, orig12, diff1, diff2, diff12, name, rule_time, binding, last, internal1, internal2, internal12, s.pid)

    # Tenyleges vegrehajtas! Utana a valtozasok kiszedese.
    # orig -diff-> start -stage-> internal
    stage = function.(stage)
    # Logger.warn(" store: #{name} =====stage1======> #{inspect stage.stage1, pretty: true} ")
    # Logger.warn(" store: #{name} =====internal======> #{inspect internal1, pretty: true} ")
    diff1 = stage.stage1 |> Mlmap.filter(internal1)
    diff2 = stage.stage2 |> Mlmap.filter(internal2)
    diff12 = stage.stage12 |> Mlmap.filter(internal12)
    # Logger.warn(" store: #{name} ======diff1====> #{inspect diff1, pretty: true} ")

    # Tortent-e valtozas?
    if Map.size(diff1) != 0 or Map.size(diff2) != 0 or Map.size(diff12) != 0 do
      ver_num = if real, do: ver_num_delete(s.ver_num, rule_time), else: s.ver_num
      ver_num = ver_num_delete(ver_num, last)
      lastp1 = last + 1
      ver_num = Map.put(ver_num, lastp1, if(real, do: 2, else: 1))

      # Valtozasok atvezetese.
      diffs1 = diffs1 |> Enum.filter(fn {k, _d} -> Map.get(ver_num, k, 0) > 0 end) |> Enum.map(fn {k, d} -> {k, Mlmap.merge(d, diff1)} end)
      diffs1 = [{last, diff1} | diffs1]
      diffs2 = diffs2 |> Enum.filter(fn {k, _d} -> Map.get(ver_num, k, 0) > 0 end) |> Enum.map(fn {k, d} -> {k, Mlmap.merge(d, diff2)} end)
      diffs2 = [{last, diff2} | diffs2]
      diffs12 = diffs12 |> Enum.filter(fn {k, _d} -> Map.get(ver_num, k, 0) > 0 end) |> Enum.map(fn {k, d} -> {k, Mlmap.merge(d, diff12)} end)
      diffs12 = [{last, diff12} | diffs12]

      mod1 = diff1 |> Map.keys() |> Enum.map(fn x -> {x, lastp1} end) |> Map.new()
      mod2 = diff2 |> Map.keys() |> Enum.map(fn x -> {x, lastp1} end) |> Map.new()
      mod12 = diff12 |> Map.keys() |> Enum.map(fn x -> {x, lastp1} end) |> Map.new()

      %{
        s
        | diffs1: Map.new(diffs1),
          diffs2: Map.new(diffs2),
          diffs12: Map.new(diffs12),
          origs1: Map.put(origs1, last, internal1),
          origs2: Map.put(origs2, last, internal2),
          origs12: Map.put(origs12, last, internal12),
          last: lastp1,
          rules_ver: if(real, do: Map.put(s.rules_ver, name, lastp1), else: s.rules_ver),
          # Ez biztosan uj itt.
          ver_num: ver_num,
          last_mod1: Map.merge(s.last_mod1, mod1),
          last_mod2: Map.merge(s.last_mod2, mod2),
          last_mod12: Map.merge(s.last_mod12, mod12),
          internal1: stage.internal1,
          internal2: stage.internal2,
          internal12: stage.internal12
      }
    else
      if real, do: ver_num_bump(s, last, name, rule_time), else: s
    end
  end

  @spec ver_num_bump(t, Integer.t(), String.t(), Integer.t()) :: t
  def ver_num_bump(s, last, name, rule_time) do
    # A rule felhozasa a mostanira.
    ver_num = ver_num_delete(s.ver_num, rule_time)
    ver_num = Map.update(ver_num, last, 1, fn x -> x + 1 end)
    %{s | ver_num: ver_num, rules_ver: Map.put(s.rules_ver, name, last)}
  end

  @spec ver_num_delete(%{Integer.t() => Integer.t()}, Integer.t()) :: %{Integer.t() => Integer.t()}
  def ver_num_delete(ver_num, rule_time) do
    if rule_time == 0 do
      ver_num
    else
      Map.get_and_update(ver_num, rule_time, fn current -> if(current == 1, do: :pop, else: {current, current - 1}) end) |> elem(1)
    end
  end

  ######          ########   #######  ##      ##          ######
  ##              ##     ## ##     ## ##  ##  ##              ##
  ##              ##     ## ##     ## ##  ##  ##              ##
  ##              ########  ##     ## ##  ##  ##              ##
  ##              ##   ##   ##     ## ##  ##  ##              ##
  ##              ##    ##  ##     ## ##  ##  ##              ##
  ######          ##     ##  #######   ###  ###           ######

  @spec individual_burst(t, Rule.burst()) :: t
  def individual_burst(s, burst) do
    s.rules |> Enum.filter(fn {_n, m} -> m.burst == burst end) |> Enum.map(fn {n, _m} -> n end) |> Enum.reduce(s, fn n, acc -> execute(acc, n) end)
  end

  @spec full_burst(t, Rule.burst()) :: t
  def full_burst(s, burst) do
    s = %{s | first: Map.put(s.first, burst, s.last)}
    s = individual_burst(s, burst)
    if s.last != s.first[burst], do: full_burst(s, burst), else: s
  end

  @spec cycle(t) :: t
  def cycle(s) do
    last = s.last
    lst = s.msgqueue |> Enum.reverse()

    s =
      if lst != [] do
        execute_step(
          %{s | msgqueue: [], qlen: 0},
          "input",
          0,
          %{},
          fn stage ->
            stage = Stage.put(stage, lst)
            # Logger.debug("stage: #{inspect(stage)}")
            stage
          end,
          false
        )
      else
        s
      end

    # Logger.info("sep")
    # Logger.debug("store: #{inspect(s)}")
    s = full_burst(s, :cpu)
    # Logger.info("sep")
    # Logger.debug("store_cpu: #{inspect(s)}")
    s = full_burst(s, :checkout)

    s =
      if last < s.last do
        # Felesleges verziok kiszedese
        ver_num = s.ver_num
        origs1 = s.origs1 |> Enum.filter(fn {k, _d} -> Map.get(ver_num, k, 0) > 0 end)
        origs2 = s.origs2 |> Enum.filter(fn {k, _d} -> Map.get(ver_num, k, 0) > 0 end)
        origs12 = s.origs12 |> Enum.filter(fn {k, _d} -> Map.get(ver_num, k, 0) > 0 end)
        %{s | origs1: Map.new(origs1), origs2: Map.new(origs2), origs12: Map.new(origs12)}
      else
        s
      end

    # Logger.info("sep")
    # Logger.debug("store_checkout: #{inspect(s)}")
    s
  end

  ######          ######## ##     ## ######## ######## ########  ##    ##    ###    ##                ######
  ##              ##        ##   ##     ##    ##       ##     ## ###   ##   ## ##   ##                    ##
  ##              ##         ## ##      ##    ##       ##     ## ####  ##  ##   ##  ##                    ##
  ##              ######      ###       ##    ######   ########  ## ## ## ##     ## ##                    ##
  ##              ##         ## ##      ##    ##       ##   ##   ##  #### ######### ##                    ##
  ##              ##        ##   ##     ##    ##       ##    ##  ##   ### ##     ## ##                    ##
  ######          ######## ##     ##    ##    ######## ##     ## ##    ## ##     ## ########          ######

  @spec install(
          t,
          name :: Mulmap.iden(),
          binding :: Rule.binding_list(),
          observe1 :: [Mulmap.iden()],
          observe2 :: [Mulmap.iden()],
          observe12 :: [{Mulmap.iden(), Mulmap.iden()}],
          kernel :: Boolean.t(),
          burst :: Rule.burst(),
          function :: Rule.functionx(),
          constructor :: Rule.functionx() | nil,
          destructor :: Rule.functionx() | nil
        ) :: t
  def install(s, name, binding, observe1, observe2, observe12, kernel, burst, function, constructor \\ nil, destructor \\ nil) do
    rule = Rule.constructor(name, binding, observe1, observe2, observe12, kernel, burst, function, constructor, destructor)
    first = Map.put(s.first, burst, 0)
    rules = Map.put(s.rules, name, rule)
    s = %{s | first: first, rules: rules}
    if constructor != nil, do: execute_step(s, name, 0, rule.binding, constructor, false), else: s
  end

  @spec uninstall(t, Mulmap.iden()) :: t
  def uninstall(s, name) do
    rules = s.rules
    rule = Map.get(rules, name, nil)

    if rule != nil do
      rules = Map.delete(rules, name)
      rules_ver = s.rules_ver
      rule_time = Map.get(rules_ver, name, 0)
      rules_ver = Map.delete(rules_ver, name)
      ver_num = ver_num_delete(s.ver_num, rule_time)
      s = %{s | rules: rules, rules_ver: rules_ver, ver_num: ver_num}
      destructor = rule.destructor
      if destructor != nil, do: execute_step(s, name, rule_time, rule.binding, destructor, false), else: s
    else
      s
    end
  end

  @spec add_to_queue(t, [any], any) :: t
  def add_to_queue(s, lst, val), do: %{s | msgqueue: [{lst, val, nil} | s.msgqueue], qlen: s.qlen + 1}

  @spec set_pid(t, String.t()) :: t
  def set_pid(s, pid), do: %{s | pid: pid}

  @spec checkout_advanced(t) :: Boolean.t()
  def checkout_advanced(s), do: s.last > s.first[:checkout]

  # defmodule
end
