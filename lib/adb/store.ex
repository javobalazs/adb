alias ADB.Stage
alias ADB.Mlmap
alias ADB.Store
alias ADB.Rule

defmodule Store do
  require Util
  Util.arrow_assignment()
  require Stage
  # require Logger

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
          diffs1: %{Integer.t() => Mlmap.t_diff()},
          diffs2: %{Integer.t() => Mlmap.t_diff()},
          diffs12: %{Integer.t() => Mlmap.t_diff()},
          origs1: %{Integer.t() => Mlmap.t()},
          origs2: %{Integer.t() => Mlmap.t()},
          origs12: %{Integer.t() => Mlmap.t()},
          last_mod1: %{String.t() => Integer.t()},
          last_mod2: %{String.t() => Integer.t()},
          last_mod12: %{{String.t(), String.t()} => Integer.t()},
          rules_ver: %{String.t() => Integer.t()},
          ver_num: %{Integer.t() => Integer.t()},
          rules: %{String.t() => Rule.t()},
          last: Integer.t(),
          first: %{Rule.burst() => Integer.t()},
          internal1: Mlmap.t(),
          internal2: Mlmap.t(),
          internal12: Mlmap.t(),
          pid: String.t(),
          msgqueue: [{String.t(), any, any}],
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

        Util.wife true, !last_mod_check do
          last_mod_check = s.last_mod2 |> Map.take(rule.observe2_eff) |> Enum.reduce_while(false, fn {_k, ver}, _acc -> if(ver > rule_time, do: {:halt, true}, else: {:cont, false}) end)

          Util.wife true, !last_mod_check do
            s.last_mod12 |> Map.take(rule.observe12_eff) |> Enum.reduce_while(false, fn {_k, ver}, _acc -> if(ver > rule_time, do: {:halt, true}, else: {:cont, false}) end)
          end
        end >>> last_mod_check

        # Volt-e egyaltalan valtozas?
        if last_mod_check do
          execute_step(s, name, rule_time, rule.binding, rule.function, true, rule.burst)
        else
          ver_num_bump(s, last, name, rule_time)
        end
      end
    end

    # def execute
  end

  @spec execute_step(t, String.t(), Integer.t(), Rule.binding(), Rule.functionx(), Boolean.t(), Rule.burst()) :: t
  def execute_step(s, name, rule_time, binding, function, real, burst) do
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
    last_mod1 = s.last_mod1
    last_mod2 = s.last_mod2
    last_mod12 = s.last_mod12

    # Logger.warn("rule: #{name}, last_ver: #{inspect s.last_mod1}, rule_ver: #{inspect s.rules_ver}")

    # Diffek kiszedese, atmeneti stage letrehozasa.

    if real do
      if rule_time == 0 do
        {internal1, internal2, internal12, %{}, %{}, %{}}
      else
        {diffs1 |> Map.get(rule_time), diffs2 |> Map.get(rule_time), diffs12 |> Map.get(rule_time), origs1 |> Map.get(rule_time), origs2 |> Map.get(rule_time), origs12 |> Map.get(rule_time)}
      end
    else
      {%{}, %{}, %{}, internal1, internal2, internal12}
    end >>> {diff1, diff2, diff12, orig1, orig2, orig12}

    # Logger.warn(" store: #{name} =======store==> #{inspect s, pretty: true} ")
    # if name == "81store" do
    #   Logger.warn("81store diff1: #{inspect diff1}")
    #   Logger.warn("81store diff2: #{inspect diff2}")
    #   Logger.warn("81store diff12: #{inspect diff12}")
    # end
    # if name == "02lock" do
    #   Logger.warn("02lock diff1: #{inspect diff1}")
    #   Logger.warn("02lock diff2: #{inspect diff2}")
    #   Logger.warn("02lock diff12: #{inspect diff12}")
    # end

    # Elokeszites...
    stage = Stage.mconstructor(orig1, orig2, orig12, diff1, diff2, diff12, name, rule_time, binding, last, internal1, internal2, internal12, last_mod1, last_mod2, last_mod12, real, s.pid, burst)

    # Tenyleges vegrehajtas! Utana a valtozasok kiszedese.
    # orig -diff-> start -stage-> internal
    stage = function.(stage)
    # Logger.warn(" store: #{name} =====stage1======> #{inspect stage.stage1, pretty: true} ")
    # Logger.warn(" store: #{name} =====internal======> #{inspect internal1, pretty: true} ")

    diff1 = stage.stage1
    diff2 = stage.stage2
    # Logger.warn("stage.stage12: #{inspect stage.stage12}, internal12: #{inspect internal12}, vegleges: #{inspect stage.internal12}")
    diff12 = stage.stage12
    # Logger.warn(" store: #{name} ======diff1====> #{inspect diff1, pretty: true} ")
    # Logger.warn("diff12: #{inspect diff12}")

    # if name == "81store" do
    #   Logger.warn("81store udiff1: #{inspect diff1}")
    #   Logger.warn("81store udiff2: #{inspect diff2}")
    #   Logger.warn("81store udiff12: #{inspect diff12}")
    # end
    # if name == "02lock" do
    #   Logger.warn("02lock udiff1: #{inspect diff1}")
    #   Logger.warn("02lock udiff2: #{inspect diff2}")
    #   Logger.warn("02lock udiff12: #{inspect diff12}")
    # end

    keep = real and stage.keep

    # Tortent-e valtozas?
    # if Map.size(diff1) != 0 or Map.size(diff2) != 0 or Map.size(diff12) != 0 do
    # Felesleges az 1-re es 12-re ellenorizni, ha azokban van valtozas, akkor az 1-ben is.

    if diff1 == :undefined or Map.size(diff1) != 0 do
      ver_num = if keep, do: ver_num_delete(s.ver_num, rule_time), else: s.ver_num
      ver_num = ver_num_delete(ver_num, last)
      lastp1 = last + 1
      ver_num = Map.put(ver_num, lastp1, if(keep, do: 2, else: 1))

      # Valtozasok atvezetese.
      diffs1 = diffs1 |> Enum.filter(fn {k, _d} -> Map.get(ver_num, k, 0) > 0 end) |> Enum.map(fn {k, d} -> {k, Mlmap.dmerge(origs1[k], d, diff1)} end)
      diffs1 = [{last, diff1} | diffs1]
      diffs2 = diffs2 |> Enum.filter(fn {k, _d} -> Map.get(ver_num, k, 0) > 0 end) |> Enum.map(fn {k, d} -> {k, Mlmap.dmerge(origs2[k], d, diff2)} end)
      diffs2 = [{last, diff2} | diffs2]
      diffs12 = diffs12 |> Enum.filter(fn {k, _d} -> Map.get(ver_num, k, 0) > 0 end) |> Enum.map(fn {k, d} -> {k, Mlmap.dmerge(origs12[k], d, diff12)} end)
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
          rules_ver: if(keep, do: Map.put(s.rules_ver, name, lastp1), else: s.rules_ver),
          # Ez biztosan uj itt.
          ver_num: ver_num,
          last_mod1: Map.merge(last_mod1, mod1),
          last_mod2: Map.merge(last_mod2, mod2),
          last_mod12: Map.merge(last_mod12, mod12),
          internal1: stage.internal1,
          internal2: stage.internal2,
          internal12: stage.internal12
      }
    else
      Util.wife(s, keep, do: ver_num_bump(s, last, name, rule_time))
    end >>> s

    # Az msgqueue kezelese fuggetlen attol, hogy valtoztatott-e vagy `!keep`,
    # mivel siman lehet, hogy a hibas imperativ muveletet akarja jelezni csak,
    # es a hiba miatt nem volt valtoztatas, es az ujracsinalas miatt a verziot sem akarja novelni.
    Util.wife(s, burst == :checkout, do: %{s | msgqueue: stage.msgqueue ++ s.msgqueue, qlen: stage.qlen + s.qlen})
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

    Util.wife s, lst != [] do
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
        false,
        :checkin
      )
    end >>> s

    # Logger.info("sep")
    # Logger.debug("store: #{inspect(s)}")
    # A tobbi `:checkin`
    s = full_burst(s, :checkin)
    # Logger.info("sep")
    # Logger.debug("store: #{inspect(s)}")
    s = full_burst(s, :cpu)
    # Logger.info("sep")
    # Logger.debug("store_cpu: #{inspect(s)}")
    s = full_burst(s, :checkout)

    Util.wife s, last < s.last do
      # Felesleges verziok kiszedese
      ver_num = s.ver_num
      origs1 = s.origs1 |> Enum.filter(fn {k, _d} -> Map.get(ver_num, k, 0) > 0 end)
      origs2 = s.origs2 |> Enum.filter(fn {k, _d} -> Map.get(ver_num, k, 0) > 0 end)
      origs12 = s.origs12 |> Enum.filter(fn {k, _d} -> Map.get(ver_num, k, 0) > 0 end)
      %{s | origs1: Map.new(origs1), origs2: Map.new(origs2), origs12: Map.new(origs12)}
    end >>> s

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

  @doc """
  A konstruktor `:checkin`-burst-ben fut,
  de igazabol majdnem lenyegtelen, mert ahol ez fut,
  ott mar elvileg ugyis azonnal futnia kell a `cycle`-nak.
  """
  @spec install(
          t,
          name :: String.t(),
          binding :: Rule.binding_list(),
          observe1 :: [String.t()],
          observe2 :: [String.t()],
          observe12 :: [{String.t(), String.t()}],
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
    Util.wife(s, constructor != nil, do: execute_step(s, name, 0, rule.binding, constructor, true, :checkin))
  end

  @spec uninstall(t, String.t()) :: t
  def uninstall(s, name) do
    rules = s.rules
    rule = Map.get(rules, name, nil)

    Util.wife s, rule != nil do
      rules = Map.delete(rules, name)
      rules_ver = s.rules_ver
      rule_time = Map.get(rules_ver, name, 0)
      rules_ver = Map.delete(rules_ver, name)
      ver_num = ver_num_delete(s.ver_num, rule_time)
      s = %{s | rules: rules, rules_ver: rules_ver, ver_num: ver_num}
      destructor = rule.destructor
      Util.wife(s, destructor != nil, do: execute_step(s, name, rule_time, rule.binding, destructor, false, :checkin))
    end
  end

  @spec add_to_queue(t, [{String.t(), any, any}], any) :: t
  def add_to_queue(s, lst, val), do: %{s | msgqueue: [{lst, val, nil} | s.msgqueue], qlen: s.qlen + 1}

  @spec set_pid(t, String.t()) :: t
  def set_pid(s, pid), do: %{s | pid: pid}

  @spec checkout_fallthrough(t) :: Boolean.t()
  def checkout_fallthrough(s), do: s.qlen > 0

  # defmodule
end
