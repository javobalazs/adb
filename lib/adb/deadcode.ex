

  # ######          #### ##    ## ######## ######## ########  ##    ##    ###    ##                ######
  # ##               ##  ###   ##    ##    ##       ##     ## ###   ##   ## ##   ##                    ##
  # ##               ##  ####  ##    ##    ##       ##     ## ####  ##  ##   ##  ##                    ##
  # ##               ##  ## ## ##    ##    ######   ########  ## ## ## ##     ## ##                    ##
  # ##               ##  ##  ####    ##    ##       ##   ##   ##  #### ######### ##                    ##
  # ##               ##  ##   ###    ##    ##       ##    ##  ##   ### ##     ## ##                    ##
  # ######          #### ##    ##    ##    ######## ##     ## ##    ## ##     ## ########          ######
  #
  # @type ti :: %{any => %{any => any}}
  #
  # @doc "update"
  # @spec updi(ti, String.t(), any, any) :: ti
  # def updi(mm, map, key, val), do: Map.update(mm, map, %{key => val}, fn x -> Map.put(x, key, val) end)
  #
  # @doc "merge"
  # @spec mrgi(ti, ti) :: ti
  # def mrgi(mm1, mm2), do: Map.merge(mm1, mm2, fn _map, mp1, mp2 -> Map.merge(mp1, mp2) end)
  #
  # @spec takei(ti, [String.t()]) :: ti
  # def takei(mm, lst), do: Map.take(mm, lst)
  #
  # @spec getmapi(ti, String.t(), Map.t() | nil) :: Map.t() | nil
  # def getmapi(s, map, dval \\ nil), do: Map.get(s, map, dval)
  #
  # @spec geti(ti, String.t(), any, any) :: any
  # def geti(s, map, key, dval \\ :undefined) do
  #   case Map.get(s, map, nil) do
  #     nil -> dval
  #     mp -> Map.get(mp, key, dval)
  #   end
  # end
  #
  # @spec puti(ti, String.t(), any, any) :: ti
  # def puti(s, map, key, val), do: Map.update(s, map, %{key => val}, fn mp -> Map.put(mp, key, val) end)



  #
  # defmodule ADB0 do
  #   @vsn "0.1.0"
  #   require Logger
  #
  #   @mnesia_wait_for_tables_timeout 3_000
  #
  #   @moduledoc """
  #   - TODO szamlalo adatbazisbol
  #   - TODO observer/trigger
  #   - TODO internal
  #   """
  #
  #   defstruct             stage: %{},
  #             diffs: %{},
  #             last: 20,
  #             first: 20,
  #             last_mod: %{},
  #             internal: %{},
  #             qu_cpu: :queue.new(),
  #             qu_cpu_old: :queue.new(),
  #             qu_io: :queue.new(),
  #             qu_io_old: :queue.new(),
  #             rule_ver: %{}
  #
  #   @type t :: %__MODULE__{
  #           # Osszevont kulcs `{map, key}`
  #           stage: mulmap_t,
  #           diffs: %{Integer.t() => mulmap_t},
  #           last: Integer.t(),
  #           first: Integer.t(),
  #           last_mod: %{any => Integer.t()},
  #           internal: %{any => %{any => any}},
  #           qu_cpu: :queue.queue(String.t()),
  #           qu_cpu_old: :queue.queue(String.t()),
  #           qu_io: :queue.queue(String.t()),
  #           qu_io_old: :queue.queue(String.t()),
  #           rule_ver: %{String.t() => Integer.t()}
  #         }
  #
  #
  #
  #   @type binding_t :: [{any, any}]
  #   @type observe_t :: List.t()
  #   @type rule_t :: %{
  #           name: String.t(),
  #           binding: binding_t,
  #           observe: observe_t,
  #           module: atom,
  #           function: atom
  #         }
  #
  #   ######          #### ##    ## #### ########          ######
  #   ##               ##  ###   ##  ##     ##                 ##
  #   ##               ##  ####  ##  ##     ##                 ##
  #   ##               ##  ## ## ##  ##     ##                 ##
  #   ##               ##  ##  ####  ##     ##                 ##
  #   ##               ##  ##   ###  ##     ##                 ##
  #   ######          #### ##    ## ####    ##             ######
  #
  #   def init(levels \\ 5) do
  #     x = :mnesia.system_info(:use_dir)
  #
  #     if !x do
  #       Logger.warn("| ADB | create |")
  #       :mnesia.stop()
  #       :mnesia.create_schema([node()])
  #       :mnesia.start()
  #     else
  #       Logger.warn("| ADB | exist |")
  #     end
  #
  #     res =
  #       case :mnesia.create_table(:persistent, disc_copies: [node()], attributes: [:key, :value], type: :ordered_set) do
  #         {:atomic, :ok} ->
  #           Logger.warn("| ADB | data | created |")
  #           :ok
  #
  #         {:aborted, {:already_exists, _a}} ->
  #           Logger.warn("| ADB | data | already |")
  #           :ok
  #
  #         {:aborted, a} ->
  #           Logger.warn("| ADB | data | error | #{inspect(a)}")
  #           {:error, :create_table}
  #       end
  #
  #     res =
  #       if res == :ok do
  #         case :mnesia.create_table(:ephemeral, ram_copies: [node()], attributes: [:key, :value], type: :ordered_set) do
  #           {:atomic, :ok} ->
  #             Logger.warn("| ADB | data | created |")
  #             :ok
  #
  #           {:aborted, {:already_exists, _a}} ->
  #             Logger.warn("| ADB | data | already |")
  #             :ok
  #
  #           {:aborted, a} ->
  #             Logger.warn("| ADB | data | error | #{inspect(a)}")
  #             {:error, :create_table}
  #         end
  #       end
  #
  #     if res == :ok do
  #       :mnesia.wait_for_tables([:persistent, :ephemeral], @mnesia_wait_for_tables_timeout)
  #       s = constructor(levels)
  #       {:ok, s}
  #     else
  #       res
  #     end
  #   end
  #
  #   @spec constructor(Integer.t()) :: t
  #   def constructor(levels \\ 5) do
  #     %__MODULE__{qc: List.duplicate(%{}, levels)}
  #   end
  #
  #   ######          ########  ##     ## ##       ########  ######           ######
  #   ##              ##     ## ##     ## ##       ##       ##    ##              ##
  #   ##              ##     ## ##     ## ##       ##       ##                    ##
  #   ##              ########  ##     ## ##       ######    ######               ##
  #   ##              ##   ##   ##     ## ##       ##             ##              ##
  #   ##              ##    ##  ##     ## ##       ##       ##    ##              ##
  #   ######          ##     ##  #######  ######## ########  ######           ######
  #
  #   @spec install(t, String.t(), binding_t, observe_t, %{any => mode_t}, atom, atom) :: t
  #   def install(s, name, binding, observe, place, module, function) do
  #     rule = %{
  #       name: name,
  #       binding: binding,
  #       observe: observe,
  #       module: module,
  #       function: function
  #     }
  #
  #     put(s, {"meta_rules", name}, rule, :persistent)
  #     # TODO placing. Vagy trigger? Sajat farkaba harap?
  #   end
  #
  #   @spec uninstall(t, String.t) :: t
  #   def uninstall(s, rule_name) do
  #     # Elvileg a tobbit a triggerek intezik.
  #      put(s, {"meta_rules", rule_name}, :undefined)
  #    end
  #
  #   @spec execute(t, rule_t) :: t
  #   def execute(s, name) do
  #       name = rule.name
  #       last_mod = Map.get(rule_ver, name, nil)
  #       last = s.last
  #
  #       observe = s.binding |> Map.take(s.observe)
  #
  #       diffs = s.diffs
  #
  #       {s, mod} =
  #         if last_mod == nil do
  #           observe
  #           |> Enum.reduce({s, []}, fn {bname, map}, {s, acc} ->
  #             {s, lst} = range(s, map, -1, :undefined)
  #             {s, [{bname, Map.new(lst)} | acc]}
  #           end)
  #         else
  #           s_last_mod = s.last_mod
  #
  #           lst =
  #             observe
  #             |> Enum.reduce([], fn {bname, map}, acc ->
  #               ver = Map.get(s_last_mod, map, nil)
  #
  #               if ver != nil and ver > last_mod do
  #                 [{bname, diffs[map]} | acc]
  #               else
  #                 acc
  #               end
  #             end)
  #
  #           {s, lst}
  #         end
  #
  #       s = %{s | rule_ver: Map.put(s.rule_ver, name, last)}
  #
  #       if mod == [] do
  #         {s, true}
  #       else
  #         # Tenyleges vegrehajtas!
  #         s = apply(rule.module, rule.function, [s, name, rule.binding, observe, last_mod, last, Map.new(mod)])
  #         stage = s.stage |> mulmap_flt
  #         s = %{s| stage: %{}}
  #
  #         if Map.size(stage) == 0 do
  #           s
  #         else
  #           diffs = diffs |> Enum.filter(fn {k, _d} -> k >= last_mod end) |> Enum.map(fn {k, d} -> {k, mulmap_mrg(d, stage) |> mulmap_flt} end)
  #           diffs = [{last, stage} | diffs]
  #           %{s | first: last_mod, diffs: Map.new(diffs), last: last + 1}
  #         end
  #       end
  #   end
  #
  #   def step_aux(s) do
  #     case rules do
  #       [] ->
  #       [name|rest] ->
  #             {s, rule} = get(s, {"meta_rules", name}, :persistent, :undefined)
  #
  #             if rule == :undefined do
  #               %{s | rule_ver: Map.delete(s.rule_ver, name)}
  #             else
  #
  #
  #     qu = s.qu
  #     {next, qu} = :queue.out(qu)
  #     case next do
  #       :empty ->
  #       {_, rule} ->
  #     end
  #   end
  #
  #   @spec dump(t) :: t
  #   def dump(s) do
  #     # Dump
  #     s.persistent
  #     |> Enum.each(fn {real_key, val} ->
  #       # Logger.info("k: #{inspect(real_key)}, v: #{inspect(val)}")
  #       case val do
  #         :undefined -> :mnesia.dirty_delete(:data, real_key)
  #         _ -> :mnesia.dirty_write({:data, real_key, val})
  #       end
  #     end)
  #
  #     s = %{s | persistent: %{}}
  #
  #     dump_counter = s.dump_counter + 1
  #
  #     # Rotate
  #     s =
  #       if dump_counter >= s.rotate_at_dump do
  #         qc = Enum.reverse(s.qc)
  #         [_ | qc] = qc
  #         qc = [%{} | Enum.reverse(qc)]
  #         %{s | qc: qc, dump_counter: 0}
  #       else
  #         %{s | dump_counter: dump_counter}
  #       end
  #
  #     s
  #   end
  #
  #   @spec step(t) :: t
  #   def step(s) do
  #     last = s.last
  #
  #     # Itt tenylegesen ki lehet irni az ephemeralt.
  #     # Persisntet kiirasa felesleges.
  #     # eph = s.ephemeral
  #     stages = Map.put(s.stages, last, s.oldm)
  #     newm = s.newm
  #     newtop = newm |> Enum.reduce(%{}, fn {{m, k}, v}, acc -> mapmap_put(acc, m, k, v) end)
  #
  #     diffs = s.diffs |> Enum.map(fn {st, df} -> {st, mapmap_mrg(df, newtop)} end)
  #     diffs = [{last, newtop} | diffs] |> Map.new()
  #     %{s | ephemeral: %{}, newm: %{}, oldm: newm, stages: stages, diffs: diffs, last: last + 1}
  #   end
  #
  #   @spec skip(t, pos_integer) :: t
  #   def skip(s, n) do
  #     last = s.last
  #     first = s.first
  #     nfirst = first + n
  #     nfirst = if nfirst > last, do: last, else: nfirst
  #
  #     if nfirst > first do
  #       stages = s.stages |> Enum.filter(fn {k, _v} -> k >= nfirst end) |> Map.new()
  #       diffs = s.diffs |> Enum.filter(fn {k, _v} -> k >= nfirst end) |> Map.new()
  #       %{s | diffs: diffs, stages: stages, first: nfirst}
  #     else
  #       s
  #     end
  #   end
  #
  #
  #
  #
  # end
  #

# # Regi ADB
#
# defmodule ADB do
#   @vsn "0.1.0"
#   require Logger
#
#   @mnesia_wait_for_tables_timeout 3_000
#
#   @moduledoc """
#   - TODO szamlalo adatbazisbol
#   - TODO observer/trigger
#   - TODO ephemeral
#   """
#
#   defstruct qc: [],
#             ephemeral: %{},
#             persistent: %{},
#             newm: %{},
#             oldm: %{},
#             stages: %{},
#             diffs: %{},
#             last: 20,
#             first: 20,
#             rotate_at_dump: 5,
#             dump_counter: 0,
#             last_mod: %{}
#
#   @type t :: %__MODULE__{
#           # Osszevont kulcs `{map, key}`
#           qc: qc_t,
#           # Osszevont kulcs `{map, key}`
#           ephemeral: Map.t(),
#           # Osszevont kulcs `{map, key}`
#           persistent: Map.t(),
#           # Osszevont kulcs `{map, key}`
#           newm: Map.t(),
#           # Osszevont kulcs `{map, key}`
#           oldm: Map.t(),
#           # Osszevont kulcs `{map, key}`
#           stages: %{Integer.t() => Map.t()},
#           # Map-onkent kulonallo almap-ek
#           diffs: %{Integer.t() => Map.t()},
#           last: Integer.t(),
#           first: Integer.t(),
#           rotate_at_dump: Integer.t(),
#           dump_counter: Integer.t(),
#           last_mod: %{any => Integer.t()}
#         }
#
#   @type qc_t :: [Map.t()]
#
#   @type binding_t :: Map.t
#   @type observe_t :: List.t
#
#   @type rule_t :: %{
#     last_run: Integer.t | nil,
#     binding: binding_t,
#     observe: observe_t,
#     closure: (t, binding_t, observe_t -> {t, binding_t, observe_t}),
#   }
#
#   ######          #### ##    ## #### ########          ######
#   ##               ##  ###   ##  ##     ##                 ##
#   ##               ##  ####  ##  ##     ##                 ##
#   ##               ##  ## ## ##  ##     ##                 ##
#   ##               ##  ##  ####  ##     ##                 ##
#   ##               ##  ##   ###  ##     ##                 ##
#   ######          #### ##    ## ####    ##             ######
#
#   def init(levels \\ 5) do
#     x = :mnesia.system_info(:use_dir)
#
#     if !x do
#       Logger.warn("| ADB | create |")
#       :mnesia.stop()
#       :mnesia.create_schema([node()])
#       :mnesia.start()
#     else
#       Logger.warn("| ADB | exist |")
#     end
#
#     res =
#       case :mnesia.create_table(:data, disc_copies: [node()], attributes: [:key, :value], type: :ordered_set) do
#         {:atomic, :ok} ->
#           Logger.warn("| ADB | data | created |")
#           :ok
#
#         {:aborted, {:already_exists, _a}} ->
#           Logger.warn("| ADB | data | already |")
#           :ok
#
#         {:aborted, a} ->
#           Logger.warn("| ADB | data | error | #{inspect(a)}")
#           {:error, :create_table}
#       end
#
#     if res == :ok do
#       :mnesia.wait_for_tables([:data], @mnesia_wait_for_tables_timeout)
#       s = constructor(levels)
#       {:ok, s}
#     else
#       res
#     end
#   end
#
#   @spec constructor(Integer.t()) :: t
#   def constructor(levels \\ 5) do
#     %__MODULE__{qc: List.duplicate(%{}, levels)}
#   end
#
#   ######          ##     ##    ###    ##    ##    ###     ######   ######## ##     ## ######## ##    ## ########          ######
#   ##              ###   ###   ## ##   ###   ##   ## ##   ##    ##  ##       ###   ### ##       ###   ##    ##                 ##
#   ##              #### ####  ##   ##  ####  ##  ##   ##  ##        ##       #### #### ##       ####  ##    ##                 ##
#   ##              ## ### ## ##     ## ## ## ## ##     ## ##   #### ######   ## ### ## ######   ## ## ##    ##                 ##
#   ##              ##     ## ######### ##  #### ######### ##    ##  ##       ##     ## ##       ##  ####    ##                 ##
#   ##              ##     ## ##     ## ##   ### ##     ## ##    ##  ##       ##     ## ##       ##   ###    ##                 ##
#   ######          ##     ## ##     ## ##    ## ##     ##  ######   ######## ##     ## ######## ##    ##    ##             ######
#
#   @spec dump(t) :: t
#   def dump(s) do
#     # Dump
#     s.persistent
#     |> Enum.each(fn {real_key, val} ->
#       # Logger.info("k: #{inspect(real_key)}, v: #{inspect(val)}")
#       case val do
#         :undefined -> :mnesia.dirty_delete(:data, real_key)
#         _ -> :mnesia.dirty_write({:data, real_key, val})
#       end
#     end)
#
#     s = %{s | persistent: %{}}
#
#     dump_counter = s.dump_counter + 1
#
#     # Rotate
#     s =
#       if dump_counter >= s.rotate_at_dump do
#         qc = Enum.reverse(s.qc)
#         [_ | qc] = qc
#         qc = [%{} | Enum.reverse(qc)]
#         %{s | qc: qc, dump_counter: 0}
#       else
#         %{s | dump_counter: dump_counter}
#       end
#
#     s
#   end
#
#   @spec step(t) :: t
#   def step(s) do
#     last = s.last
#
#     # Itt tenylegesen ki lehet irni az ephemeralt.
#     # Persisntet kiirasa felesleges.
#     # eph = s.ephemeral
#     stages = Map.put(s.stages, last, s.oldm)
#     newm = s.newm
#     newtop = newm |> Enum.reduce(%{}, fn {{m, k}, v}, acc -> mapmap_put(acc, m, k, v) end)
#
#     diffs = s.diffs |> Enum.map(fn {st, df} -> {st, mapmap_mrg(df, newtop)} end)
#     diffs = [{last, newtop} | diffs] |> Map.new()
#     %{s | ephemeral: %{}, newm: %{}, oldm: newm, stages: stages, diffs: diffs, last: last + 1}
#   end
#
#   @spec skip(t, pos_integer) :: t
#   def skip(s, n) do
#     last = s.last
#     first = s.first
#     nfirst = first + n
#     nfirst = if nfirst > last, do: last, else: nfirst
#
#     if nfirst > first do
#       stages = s.stages |> Enum.filter(fn {k, _v} -> k >= nfirst end) |> Map.new()
#       diffs = s.diffs |> Enum.filter(fn {k, _v} -> k >= nfirst end) |> Map.new()
#       %{s | diffs: diffs, stages: stages, first: nfirst}
#     else
#       s
#     end
#   end
#
#   def mapmap_upd(mm, map, key, val), do: Map.update(mm, map, %{key => val}, fn x -> Map.update(x, key, val, fn x -> x end) end)
#   def mapmap_put(mm, map, key, val), do: Map.update(mm, map, %{key => val}, fn x -> Map.put(x, key, val) end)
#   def mapmap_mrg(mm1, mm2), do: Map.merge(mm1, mm2, fn _k, v1, v2 -> Map.merge(v1, v2) end)
#
#   ######           ######   ######## ######## ######## ######## ########           ######
#   ##              ##    ##  ##          ##       ##    ##       ##     ##              ##
#   ##              ##        ##          ##       ##    ##       ##     ##              ##
#   ##              ##   #### ######      ##       ##    ######   ########               ##
#   ##              ##    ##  ##          ##       ##    ##       ##   ##                ##
#   ##              ##    ##  ##          ##       ##    ##       ##    ##               ##
#   ######           ######   ########    ##       ##    ######## ##     ##          ######
#
#   @spec getdp(t, any, any, any) :: {t, any}
#   def getdp(s, map, key, dval \\ :undefined), do: get(s, {map, key}, :persistent, dval)
#
#   @spec get(t, any, :persistent | :ephemeral, any) :: {t, any}
#   def get(s, real_key, mode, dval) do
#     [top | rest] = s.qc
#
#     case Map.fetch(top, real_key) do
#       :error ->
#         val = get_aux(rest, real_key, mode)
#         qc = [Map.put(top, real_key, val) | rest]
#
#         s = %{s | qc: qc, oldm: Map.update(s.oldm, real_key, val, fn x -> x end)}
#
#         if val == :undefined do
#           {s, dval}
#         else
#           {s, val}
#         end
#
#       {:ok, val} ->
#         {s, val}
#     end
#   end
#
#   @spec get_aux(qc_t, any, :persistent | :ephemeral) :: any
#   defp get_aux(qc, key, mode) do
#     case qc do
#       [] ->
#         case :mnesia.dirty_read(:data, key) do
#           [] ->
#             # Logger.info("READ: #{inspect(key)}, v: undefined")
#             :undefined
#
#           [{_tab, _k, v}] ->
#             # Logger.info("READ: #{inspect(key)}, v: #{inspect(v)}")
#             v
#         end
#
#       [top | rest] ->
#         case Map.fetch(top, key) do
#           :error -> get_aux(rest, key, mode)
#           {:ok, x} -> x
#         end
#     end
#   end
#
#   ######           ######  ######## ######## ######## ######## ########           ######
#   ##              ##    ## ##          ##       ##    ##       ##     ##              ##
#   ##              ##       ##          ##       ##    ##       ##     ##              ##
#   ##               ######  ######      ##       ##    ######   ########               ##
#   ##                    ## ##          ##       ##    ##       ##   ##                ##
#   ##              ##    ## ##          ##       ##    ##       ##    ##               ##
#   ######           ######  ########    ##       ##    ######## ##     ##          ######
#
#   @spec putp(t, any, any, any) :: t
#   def putp(s, map, key, val), do: put(s, {map, key}, val, false, :persistent)
#
#   @spec putgp(t, any, any, any) :: t
#   def putgp(s, map, key, val), do: put(s, {map, key}, val, true, :persistent)
#
#   @spec put(t, {any, any}, any, Boolean.t(), :persistent | :ephemeral) :: t
#   def put(s, real_key, val, get, mode) do
#     s = if get, do: get(s, real_key, mode, :undefined) |> elem(0), else: s
#     [top | rest] = s.qc
#     qc = [Map.put(top, real_key, val) | rest]
#     persistent = Map.put(s.persistent, real_key, val)
#     newm = Map.put(s.newm, real_key, val)
#     {map, _} = real_key
#     last_mod = Map.put(s.last_mod, map, s.last)
#     %{s | qc: qc, persistent: persistent, newm: newm, last_mod: last_mod}
#   end
#
#   ######          ########     ###    ##    ##  ######   ########          ######
#   ##              ##     ##   ## ##   ###   ## ##    ##  ##                    ##
#   ##              ##     ##  ##   ##  ####  ## ##        ##                    ##
#   ##              ########  ##     ## ## ## ## ##   #### ######                ##
#   ##              ##   ##   ######### ##  #### ##    ##  ##                    ##
#   ##              ##    ##  ##     ## ##   ### ##    ##  ##                    ##
#   ######          ##     ## ##     ## ##    ##  ######   ########          ######
#
#   @spec rangep(t, any, any, any) :: {t, [{any, any}]}
#   def rangep(s, map, key1, key2), do: range(s, map, key1, key2, :persistent)
#
#   @spec range(t, any, any, any, :persistent | :ephemeral) :: {t, [{any, any}]}
#   def range(s, map, key1, key2, mode) do
#     case mode do
#       :persistent ->
#         {s, acc} = range_persistent(s, map, :mnesia.dirty_next(:data, {map, key1}), key2, [])
#         {s, Enum.reverse(acc)}
#
#       :ephemeral ->
#         {s, []}
#     end
#   end
#
#   @spec range_persistent(t, any, any, any, [{any, any}]) :: {t, [{any, any}]}
#   def range_persistent(s, map, key1, key2, acc) do
#     key1 = if key2 == :undefined, do: key1, else: :"$end_of_table"
#
#     case key1 do
#       :"$end_of_table" ->
#         {s, acc}
#
#       # Normal map.
#       {m, k} ->
#         if map == m and (key2 == :undefined or k < key2) do
#           {s, val} = get(s, key1, :persistent, :undefined)
#
#           acc = if val == :undefined, do: acc, else: [{k, val} | acc]
#
#           range_persistent(s, map, :mnesia.dirty_next(:data, key1), key2, acc)
#         else
#           {s, acc}
#         end
#
#         # _ -> {s, acc}
#     end
#   end
# end
#


  # alias ADB.Mulmap
  #
  # defmodule Mulmap do
  #   @vsn "0.1.0"
  #   @moduledoc """
  #   Trivialis ketszintu map, valtozaskoveteshez, ket valtozatban. Trivialis adatszerkezet amugy.
  #
  #   `@vsn "#{@vsn}"`
  #   """
  #
  #   ######           ######  ########    ###    ##    ## ########     ###    ########  ########           ######
  #   ##              ##    ##    ##      ## ##   ###   ## ##     ##   ## ##   ##     ## ##     ##              ##
  #   ##              ##          ##     ##   ##  ####  ## ##     ##  ##   ##  ##     ## ##     ##              ##
  #   ##               ######     ##    ##     ## ## ## ## ##     ## ##     ## ########  ##     ##              ##
  #   ##                    ##    ##    ######### ##  #### ##     ## ######### ##   ##   ##     ##              ##
  #   ##              ##    ##    ##    ##     ## ##   ### ##     ## ##     ## ##    ##  ##     ##              ##
  #   ######           ######     ##    ##     ## ##    ## ########  ##     ## ##     ## ########           ######
  #
  #   @typedoc "Maga az ertek-tipus."
  #   @type scalar :: any | :undefined
  #
  #   @typedoc "Az elemi ertek-valtozas."
  #   @type diff :: {scalar, scalar}
  #
  #   @typedoc "A kulcs az alap-adattipusban barmi lehet."
  #   @type key :: any
  #
  #   @typedoc "Egy veges map, a valtozasoknak."
  #   @type diffmap :: %{key => diff}
  #
  #   @typedoc "Az identitas, ti. ami valtozhat az idoben."
  #   @type iden :: String.t()
  #
  #   @typedoc "A teljes adatbazis."
  #   @type t :: %{String.t() => diffmap}
  #
  #   @doc "update"
  #   @spec upd(t, iden, key, scalar, scalar) :: t
  #   def upd(mm, map, key, val, old), do: Map.update(mm, map, %{key => {old, val}}, fn x -> Map.update(x, key, {old, val}, fn {oldold, _valval} -> {oldold, val} end) end)
  #
  #   @doc "delete"
  #   @spec del(t, iden, key) :: t
  #   def del(mm, map, key) do
  #     mp = Map.get(mm, map, nil)
  #
  #     case mp do
  #       nil ->
  #         mm
  #
  #       _ ->
  #         {val, mp} = Map.pop(mp, key, nil)
  #
  #         case val do
  #           nil -> mm
  #           _ -> if Map.size(mp) == 0, do: Map.delete(mm, map), else: Map.put(mm, map, mp)
  #         end
  #     end
  #   end
  #
  #   @doc "merge"
  #   @spec mrg(t, t) :: t
  #   def mrg(mm1, mm2), do: Map.merge(mm1, mm2, fn _map, mp1, mp2 -> Map.merge(mp1, mp2, fn _key, {o1, _v1}, {_v1_, v2} -> {o1, v2} end) end)
  #
  #   @spec take(t, [iden]) :: t
  #   def take(mm, lst), do: Map.take(mm, lst)
  #
  #   @spec getmap(t, iden, diffmap | nil) :: diffmap | nil
  #   def getmap(s, map, dval \\ nil), do: Map.get(s, map, dval)
  #
  #   @spec getd(t, iden, key, diff) :: diff
  #   def getd(s, map, key, dval \\ {:undefined, :undefined}) do
  #     case Map.get(s, map, nil) do
  #       nil -> dval
  #       mp -> Map.get(mp, key, dval)
  #     end
  #   end
  #
  #   @doc "Skalarist ad vissza, akkor erdekes, ha a nullmap-bol kerdezunk le."
  #   @spec getm(diffmap, key, scalar) :: scalar
  #   def getm(map, key, dval \\ :undefined) do
  #     case Map.get(map, key, nil) do
  #       nil -> dval
  #       val -> val |> elem(1)
  #     end
  #   end
  #
  #   @doc "Skalarist ad vissza, akkor erdekes, ha a nullmap-bol kerdezunk le."
  #   @spec get(t, iden, key, scalar) :: scalar
  #   def get(s, map, key, dval \\ :undefined) do
  #     case Map.get(s, map, nil) do
  #       nil -> dval
  #       mp -> Map.get(mp, key, dval) |> elem(1)
  #     end
  #   end
  #
  #   @doc """
  #   Filter, azaz csak azokat az elemeket hagyja meg, ahol `old != new`,
  #   es ezzel torli is azokat, melyek idokozben beszurodtak, de mar toroltek oket.
  #   """
  #   @spec flt(t) :: t
  #   def flt(mm) do
  #     mm
  #     |> Enum.map(fn {map, mp} ->
  #       {map, mp |> Enum.filter(fn {_k, {o, v}} -> o != v end) |> Map.new()}
  #     end)
  #     |> Enum.filter(fn {_map, mp} -> Map.size(mp) != 0 end)
  #     |> Map.new()
  #   end
  #
  #   ######            #### ##     ##    ###    ########          ##    ## ######## ##    ## ####            ######
  #   ##               ##    ###   ###   ## ##   ##     ##         ##   ##  ##        ##  ##     ##               ##
  #   ##               ##    #### ####  ##   ##  ##     ##         ##  ##   ##         ####      ##               ##
  #   ##              ###    ## ### ## ##     ## ########  ####    #####    ######      ##       ###              ##
  #   ##               ##    ##     ## ######### ##        ####    ##  ##   ##          ##       ##               ##
  #   ##               ##    ##     ## ##     ## ##         ##     ##   ##  ##          ##       ##               ##
  #   ######            #### ##     ## ##     ## ##        ##      ##    ## ########    ##    ####            ######
  #
  #   @type t2 :: %{{iden, key} => diff}
  #
  #   @doc "update"
  #   @spec upd2(t2, iden, iden, scalar, scalar) :: t2
  #   def upd2(mm, map, key, val, old), do: Map.update(mm, {map, key}, {old, val}, fn {oldold, _valval} -> {oldold, val} end)
  #
  #   @doc "delete"
  #   @spec del2(t2, iden, iden) :: t2
  #   def del2(mm, map, key), do: Map.delete(mm, {map, key})
  #
  #   @doc "merge"
  #   @spec mrg2(t2, t2) :: t2
  #   def mrg2(mm1, mm2), do: Map.merge(mm1, mm2, fn _mapkey, {o1, _v1}, {_v1_, v2} -> {o1, v2} end)
  #
  #   @doc """
  #   Filter, azaz csak azokat az elemeket hagyja meg, ahol `old != new`,
  #   es ezzel torli is azokat, melyek idokozben beszurodtak, de mar toroltek oket.
  #   """
  #   @spec flt2(t2) :: t2
  #   def flt2(mm), do: mm |> Enum.filter(fn {_mapkey, {o, v}} -> o != v end) |> Map.new()
  #
  #   @spec take2(t2, [iden]) :: t2
  #   def take2(mm, lst), do: Map.take(mm, lst)
  #
  #   @spec get2(t2, iden, iden, diff | nil) :: diff | nil
  #   def get2(s, map, key, dval \\ nil), do: Map.get(s, {map, key}, dval)
  # end

# alias ADB.Store
# alias ADB.Srv
#
# defmodule Srv do
#   @vsn "0.1.0"
#   @moduledoc """
#   Az egyszalu adatbazis szerver-modulja.
#
#   `@vsn "#{@vsn}"`
#   """
#
#   defmacro __using__([]) do
#     quote location: :keep do
#       use GenServer
#       require Logger
#       alias ADB.Store
#       # @spec start_link(name) :: GenServer.on_start()
#       # def start_link(), do: GenServer.start_link(__MODULE__, [name], name: name)
#
#       @impl true
#       @spec init(List.t()) :: {:ok, Store.t()}
#       # @spec init(List.t()) :: {:ok, Store.t} | {:stop, any}
#       def init(args) do
#         s = Store.constructor("#{__MODULE__}-#{inspect(self())}")
#         init_callback(s, args)
#       end
#
#       @spec handle_info(any, Store.t()) :: {:noreply, Store.t()}
#       @impl true
#       def handle_info(msg, s) do
#         case msg do
#           :timeout ->
#             s = Store.cycle(s)
#             if Store.checkout_advanced(s), do: {:noreply, s, 0}, else: {:noreply, s}
#
#           _ ->
#             {:noreply, handle_info_callback(s, msg), 0}
#         end
#
#         # def handle_info
#       end
#
#       @spec init_callback(Store.t(), any) :: {:ok, Store.t()} | {:stop, any}
#       # def init_callback(s, _args) do
#       #   {:ok, s}
#       # end
#
#       @spec handle_info_callback(Store.t(), any) :: Store.t()
#       # def handle_info_callback(s, _msg) do
#       #   s
#       # end
#
#       # defoverridable init_callback: 2, handle_info_callback: 2
#
#       # quote
#     end
#
#     # defmacro __using__
#   end
#
#   # defmodule
# end

# alias ADB.Mulmap
# alias ADB.Stage
# alias ADB.Rule
#
# defmodule Stage do
#   @vsn "0.1.0"
#   @moduledoc """
#
#   `@vsn "#{@vsn}"`
#   """
#
#   ######          ######## ##    ## ########  ########          ######
#   ##                 ##     ##  ##  ##     ## ##                    ##
#   ##                 ##      ####   ##     ## ##                    ##
#   ##                 ##       ##    ########  ######                ##
#   ##                 ##       ##    ##        ##                    ##
#   ##                 ##       ##    ##        ##                    ##
#   ######             ##       ##    ##        ########          ######
#
#   defstruct stage1: %{},
#             stage2: %{},
#             stage12: %{},
#             diff1: nil,
#             diff2: nil,
#             diff12: nil,
#             name: nil,
#             rule_ver: 0,
#             binding: nil,
#             last: 0,
#             internal1: nil,
#             internal2: nil,
#             internal12: nil,
#             pid: nil
#
#   @type t :: %__MODULE__{
#           stage1: Mulmap.t(),
#           stage2: Mulmap.t(),
#           stage12: Mulmap.t2(),
#           diff1: Mulmap.t(),
#           diff2: Mulmap.t(),
#           diff12: Mulmap.t2(),
#           name: String.t(),
#           rule_ver: Integer.t(),
#           binding: Rule.binding(),
#           last: Integer.t(),
#           internal1: Mulmap.t(),
#           internal2: Mulmap.t(),
#           internal12: Mulmap.t2(),
#           pid: String.t()
#         }
#
#   @type iden :: :iden | nil
#
#   ######           ######   #######  ##    ##  ######  ######## ########  ##     ##  ######  ########  #######  ########           ######
#   ##              ##    ## ##     ## ###   ## ##    ##    ##    ##     ## ##     ## ##    ##    ##    ##     ## ##     ##              ##
#   ##              ##       ##     ## ####  ## ##          ##    ##     ## ##     ## ##          ##    ##     ## ##     ##              ##
#   ##              ##       ##     ## ## ## ##  ######     ##    ########  ##     ## ##          ##    ##     ## ########               ##
#   ##              ##       ##     ## ##  ####       ##    ##    ##   ##   ##     ## ##          ##    ##     ## ##   ##                ##
#   ##              ##    ## ##     ## ##   ### ##    ##    ##    ##    ##  ##     ## ##    ##    ##    ##     ## ##    ##               ##
#   ######           ######   #######  ##    ##  ######     ##    ##     ##  #######   ######     ##     #######  ##     ##          ######
#
#   @spec constructor(
#           diff1 :: Mulmap.t(),
#           diff2 :: Mulmap.t(),
#           diff12 :: Mulmap.t2(),
#           name :: Mulmap.iden(),
#           rule_ver :: Integer.t(),
#           binding :: Rule.binding(),
#           last :: Integer.t(),
#           internal1 :: Mulmap.t(),
#           internal2 :: Mulmap.t(),
#           internal12 :: Mulmap.t2(),
#           pid :: String.t()
#         ) :: t
#   def constructor(diff1, diff2, diff12, name, rule_ver, binding, last, internal1, internal2, internal12, pid) do
#     %__MODULE__{
#       diff1: diff1,
#       diff2: diff2,
#       diff12: diff12,
#       name: name,
#       rule_ver: rule_ver,
#       binding: binding,
#       last: last,
#       internal1: internal1,
#       internal2: internal2,
#       internal12: internal12,
#       pid: pid
#     }
#   end
#
#   ######          ########  #### ######## ########          ######
#   ##              ##     ##  ##  ##       ##                    ##
#   ##              ##     ##  ##  ##       ##                    ##
#   ##              ##     ##  ##  ######   ######                ##
#   ##              ##     ##  ##  ##       ##                    ##
#   ##              ##     ##  ##  ##       ##                    ##
#   ######          ########  #### ##       ##                ######
#
#   @spec getdiff1(t, Mulmap.iden(), Mulmap.diffmap() | nil) :: Mulmap.diffmap() | nil
#   def getdiff1(s, map, dval \\ nil), do: Mulmap.getmap(s.diff1, map, dval)
#
#   @spec getdiff2(t, Mulmap.iden(), Mulmap.diffmap() | nil) :: Mulmap.diffmap() | nil
#   def getdiff2(s, key, dval \\ nil), do: Mulmap.getmap(s.diff2, key, dval)
#
#   @spec getdiff12(t, Mulmap.iden(), Mulmap.iden(), Mulmap.diff() | nil) :: {t, Mulmap.diff() | nil}
#   def getdiff12(s, map, key, dval \\ nil), do: Mulmap.get2(s.diff12, map, key, dval)
#
#   ######           ######  ########    ###     ######   ########          ######
#   ##              ##    ##    ##      ## ##   ##    ##  ##                    ##
#   ##              ##          ##     ##   ##  ##        ##                    ##
#   ##               ######     ##    ##     ## ##   #### ######                ##
#   ##                    ##    ##    ######### ##    ##  ##                    ##
#   ##              ##    ##    ##    ##     ## ##    ##  ##                    ##
#   ######           ######     ##    ##     ##  ######   ########          ######
#
#   @spec getstage1(t, Mulmap.iden(), Mulmap.diffmap() | nil) :: Mulmap.diffmap() | nil
#   def getstage1(s, map, dval \\ nil), do: Mulmap.getmap(s.stage1, map, dval)
#
#   @spec getstage2(t, Mulmap.iden(), Mulmap.diffmap() | nil) :: Mulmap.diffmap() | nil
#   def getstage2(s, key, dval \\ nil), do: Mulmap.getmap(s.stage2, key, dval)
#
#   @spec getstage12(t, Mulmap.iden(), Mulmap.iden(), Mulmap.diff() | nil) :: Mulmap.diff() | nil
#   def getstage12(s, map, key, dval \\ nil), do: Mulmap.get2(s.stage12, map, key, dval)
#
#   ######          #### ##    ## ######## ######## ########  ##    ##    ###    ##                ######
#   ##               ##  ###   ##    ##    ##       ##     ## ###   ##   ## ##   ##                    ##
#   ##               ##  ####  ##    ##    ##       ##     ## ####  ##  ##   ##  ##                    ##
#   ##               ##  ## ## ##    ##    ######   ########  ## ## ## ##     ## ##                    ##
#   ##               ##  ##  ####    ##    ##       ##   ##   ##  #### ######### ##                    ##
#   ##               ##  ##   ###    ##    ##       ##    ##  ##   ### ##     ## ##                    ##
#   ######          #### ##    ##    ##    ######## ##     ## ##    ## ##     ## ########          ######
#
#   @spec getmap1(t, Mulmap.iden(), Mulmap.diffmap() | nil) :: Mulmap.diffmap() | nil
#   def getmap1(s, map, dval \\ nil), do: Mulmap.getmap(s.internal1, map, dval)
#
#   @spec getmap2(t, Mulmap.iden(), Mulmap.diffmap() | nil) :: Mulmap.diffmap() | nil
#   def getmap2(s, key, dval \\ nil), do: Mulmap.getmap(s.internal2, key, dval)
#
#   @spec getmap12(t, Mulmap.iden(), Mulmap.iden(), Mulmap.diff() | nil) :: Mulmap.diff() | nil
#   def getmap12(s, map, key, dval \\ nil), do: Mulmap.get2(s.internal12, map, key, dval)
#
#   @spec get1(t, Mulmap.iden(), Mulmap.key(), Mulmap.scalar()) :: Mulmap.scalar()
#   def get1(s, map, key, dval \\ :undefined), do: Mulmap.get(s.internal1, map, key, dval)
#
#   @spec get2(t, Mulmap.iden(), Mulmap.iden(), Mulmap.scalar()) :: Mulmap.scalar()
#   def get2(s, key, map, dval \\ :undefined), do: Mulmap.get(s.internal2, key, map, dval)
#
#   @spec put(t, Mulmap.iden(), Mulmap.key(), Mulmap.scalar(), iden, iden, Boolean.t()) :: t
#   def put(s, map, key, val, iden_key, _iden_val \\ nil, new? \\ false) do
#     internal1 = s.internal1
#
#     # Regi, ha nem biztosan uj (vagy mar egyszer modositottuk).
#     old = if new?, do: :undefined, else: Mulmap.get(internal1, map, key)
#
#     # Internal.
#     {internal1, internal2, internal12} =
#       if old == :undefined do
#         {
#           Mulmap.del(internal1, map, key),
#           if(iden_key == :iden, do: Mulmap.del(s.internal2, key, map), else: s.internal2),
#           if(iden_key == :iden, do: Mulmap.del2(s.internal12, map, key), else: s.internal12)
#         }
#       else
#         {
#           Mulmap.upd(internal1, map, key, val, old),
#           if(iden_key == :iden, do: Mulmap.upd(s.internal2, key, map, val, old), else: s.internal2),
#           if(iden_key == :iden, do: Mulmap.upd2(s.internal12, map, key, val, old), else: s.internal12)
#         }
#       end
#
#     # Diff-ek.
#     {stage1, stage2, stage12} =
#       if old == val do
#         {
#           Mulmap.del(s.stage1, map, key),
#           if(iden_key == :iden, do: Mulmap.del(s.stage2, key, map), else: s.stage2),
#           if(iden_key == :iden, do: Mulmap.del2(s.stage12, map, key), else: s.stage12)
#         }
#       else
#         {
#           Mulmap.upd(s.stage1, map, key, val, old),
#           if(iden_key == :iden, do: Mulmap.upd(s.stage2, key, map, val, old), else: s.stage2),
#           if(iden_key == :iden, do: Mulmap.upd2(s.stage12, map, key, val, old), else: s.stage12)
#         }
#       end
#
#     # Eredmeny.
#     %{s | internal1: internal1, internal2: internal2, internal12: internal12, stage1: stage1, stage2: stage2, stage12: stage12}
#   end
#
#   @spec put(t, [{Mulmap.iden(), Mulmap.key(), Mulmap.scalar(), iden, iden, Boolean.t()}]) :: t
#   def put(s, lst) do
#     internal1 = s.internal1
#
#     lst =
#       lst
#       |> Enum.map(fn {map, key, val, iden_key, iden_val, new?} ->
#         {map, key, val, iden_key, iden_val, if(new?, do: :undefined, else: Mulmap.get(internal1, map, key))}
#       end)
#
#     # Internal.
#     {internal1, internal2, internal12} =
#       lst
#       |> Enum.reduce({internal1, s.internal2, s.internal12}, fn {map, key, val, iden_key, _iden_val, old}, {internal1, internal2, internal12} ->
#         if val == :undefined do
#           {
#             Mulmap.del(internal1, map, key),
#             if(iden_key == :iden, do: Mulmap.del(internal2, key, map), else: internal2),
#             if(iden_key == :iden, do: Mulmap.del2(internal12, map, key), else: internal12)
#           }
#         else
#           {
#             Mulmap.upd(internal1, map, key, val, old),
#             if(iden_key == :iden, do: Mulmap.upd(internal2, key, map, val, old), else: internal2),
#             if(iden_key == :iden, do: Mulmap.upd2(internal12, map, key, val, old), else: internal12)
#           }
#         end
#       end)
#
#     # Diff-ek.
#     {stage1, stage2, stage12} =
#       lst
#       |> Enum.reduce({s.stage1, s.stage2, s.stage12}, fn {map, key, val, iden_key, _iden_val, old}, {stage1, stage2, stage12} ->
#         if old == val do
#           {
#             Mulmap.del(stage1, map, key),
#             if(iden_key == :iden, do: Mulmap.del(stage2, key, map), else: stage2),
#             if(iden_key == :iden, do: Mulmap.del2(stage12, map, key), else: stage12)
#           }
#         else
#           {
#             Mulmap.upd(stage1, map, key, val, old),
#             if(iden_key == :iden, do: Mulmap.upd(stage2, key, map, val, old), else: stage2),
#             if(iden_key == :iden, do: Mulmap.upd2(stage12, map, key, val, old), else: stage12)
#           }
#         end
#       end)
#
#     # Eredmeny.
#     %{s | internal1: internal1, internal2: internal2, internal12: internal12, stage1: stage1, stage2: stage2, stage12: stage12}
#   end
# end

# alias ADB.Stage
# alias ADB.Mulmap
# alias ADB.Store
# alias ADB.Rule
#
# defmodule Store do
#   require Util
#   # require Logger
#
#   ######          ######## ##    ## ########  ########          ######
#   ##                 ##     ##  ##  ##     ## ##                    ##
#   ##                 ##      ####   ##     ## ##                    ##
#   ##                 ##       ##    ########  ######                ##
#   ##                 ##       ##    ##        ##                    ##
#   ##                 ##       ##    ##        ##                    ##
#   ######             ##       ##    ##        ########          ######
#
#   defstruct diffs1: %{},
#             diffs2: %{},
#             diffs12: %{},
#             last_mod1: %{},
#             last_mod2: %{},
#             last_mod12: %{},
#             rules_ver: %{},
#             ver_num: %{},
#             rules: %{},
#             last: 0,
#             first: %{},
#             internal1: %{},
#             internal2: %{},
#             internal12: %{},
#             pid: nil,
#             msgqueue: []
#
#   @type t :: %__MODULE__{
#           diffs1: %{Integer.t() => Mulmap.t()},
#           diffs2: %{Integer.t() => Mulmap.t()},
#           diffs12: %{Integer.t() => Mulmap.t2()},
#           last_mod1: %{Mulmap.iden() => Integer.t()},
#           last_mod2: %{Mulmap.iden() => Integer.t()},
#           last_mod12: %{{Mulmap.iden(), Mulmap.iden()} => Integer.t()},
#           rules_ver: %{Mulmap.iden() => Integer.t()},
#           ver_num: %{Integer.t() => Integer.t()},
#           rules: %{Mulmap.iden() => Rule.t()},
#           last: Integer.t(),
#           first: %{Rule.burst() => Integer.t()},
#           internal1: Mulmap.t(),
#           internal2: Mulmap.t(),
#           internal12: Mulmap.t2(),
#           pid: String.t(),
#           msgqueue: [{Mulmap.iden(), Mulmap.key(), Mulmap.scalar()}]
#         }
#
#   @spec constructor(String.t()) :: t
#   def constructor(pid), do: %__MODULE__{pid: pid}
#
#   ######           ######  #### ##    ##  ######   ##       ########          ######
#   ##              ##    ##  ##  ###   ## ##    ##  ##       ##                    ##
#   ##              ##        ##  ####  ## ##        ##       ##                    ##
#   ##               ######   ##  ## ## ## ##   #### ##       ######                ##
#   ##                    ##  ##  ##  #### ##    ##  ##       ##                    ##
#   ##              ##    ##  ##  ##   ### ##    ##  ##       ##                    ##
#   ######           ######  #### ##    ##  ######   ######## ########          ######
#
#   @spec execute(t, String.t()) :: t
#   def execute(s, name) do
#     # Cache.
#     rule = Map.get(s.rules, name, nil)
#
#     # Letezik-e egyaltalan?
#     Util.wife s, rule != nil do
#       rule_time = Map.get(s.rules_ver, name, 0)
#       last = s.last
#
#       Util.wife s, last != rule_time do
#         # Vonatkozik-e ra a dolog?
#         last_mod_check = s.last_mod1 |> Map.take(rule.observe1_eff) |> Enum.reduce_while(false, fn {_k, ver}, _acc -> if(ver > rule_time, do: {:halt, true}, else: {:cont, false}) end)
#
#         last_mod_check =
#           Util.wife true, !last_mod_check do
#             last_mod_check = s.last_mod2 |> Map.take(rule.observe2_eff) |> Enum.reduce_while(false, fn {_k, ver}, _acc -> if(ver > rule_time, do: {:halt, true}, else: {:cont, false}) end)
#
#             Util.wife true, !last_mod_check do
#               s.last_mod12 |> Map.take(rule.observe12_eff) |> Enum.reduce_while(false, fn {_k, ver}, _acc -> if(ver > rule_time, do: {:halt, true}, else: {:cont, false}) end)
#             end
#           end
#
#         # Volt-e egyaltalan valtozas?
#         if last_mod_check do
#           execute_step(s, name, rule_time, rule.binding, rule.function, true)
#         else
#           ver_num_bump(s, last, name, rule_time)
#         end
#       end
#     end
#
#     # def execute
#   end
#
#   @spec execute_step(t, Mulmap.iden(), Integer.t(), Rule.binding(), Rule.functionx(), Boolean.t()) :: t
#   def execute_step(s, name, rule_time, binding, function, real) do
#     last = s.last
#     # Valtozok kiszedese.
#     internal1 = s.internal1
#     internal2 = s.internal2
#     internal12 = s.internal12
#     diffs1 = s.diffs1
#     diffs2 = s.diffs2
#     diffs12 = s.diffs12
#
#     # Diffek kiszedese, atmeneti stage letrehozasa.
#     {diff1, diff2, diff12} =
#       if real do
#         if rule_time == 0 do
#           {internal1, internal2, internal12}
#         else
#           {diffs1 |> Map.get(rule_time), diffs2 |> Map.get(rule_time), diffs12 |> Map.get(rule_time)}
#         end
#       else
#         {%{}, %{}, %{}}
#       end
#
#     # Elokeszites...
#     stage = Stage.constructor(diff1, diff2, diff12, name, rule_time, binding, last, internal1, internal2, internal12, s.pid)
#
#     # Tenyleges vegrehajtas! Utana a valtozasok kiszedese.
#     stage = function.(stage)
#     diff1 = stage.stage1
#     diff2 = stage.stage2
#     diff12 = stage.stage12
#
#     # Tortent-e valtozas?
#     if Map.size(diff1) != 0 or Map.size(diff2) != 0 or Map.size(diff12) != 0 do
#       ver_num = if real, do: ver_num_delete(s.ver_num, rule_time), else: s.ver_num
#       ver_num = ver_num_delete(ver_num, last)
#       ver_num_diff = if real, do: 2, else: 1
#
#       # Valtozasok atvezetese.
#       diffs1 = diffs1 |> Enum.filter(fn {k, _d} -> Map.get(ver_num, k, 0) > 0 end) |> Enum.map(fn {k, d} -> {k, Mulmap.mrg(d, diff1) |> Mulmap.flt()} end)
#       diffs1 = [{last, diff1} | diffs1]
#       diffs2 = diffs2 |> Enum.filter(fn {k, _d} -> Map.get(ver_num, k, 0) > 0 end) |> Enum.map(fn {k, d} -> {k, Mulmap.mrg(d, diff2) |> Mulmap.flt()} end)
#       diffs2 = [{last, diff2} | diffs2]
#       diffs12 = diffs12 |> Enum.filter(fn {k, _d} -> Map.get(ver_num, k, 0) > 0 end) |> Enum.map(fn {k, d} -> {k, Mulmap.mrg2(d, diff12) |> Mulmap.flt2()} end)
#       diffs12 = [{last, diff12} | diffs12]
#
#       last = last + 1
#       mod1 = diff1 |> Map.keys() |> Enum.map(fn x -> {x, last} end) |> Map.new()
#       mod2 = diff2 |> Map.keys() |> Enum.map(fn x -> {x, last} end) |> Map.new()
#       mod12 = diff12 |> Map.keys() |> Enum.map(fn x -> {x, last} end) |> Map.new()
#
#       %{
#         s
#         | diffs1: Map.new(diffs1),
#           diffs2: Map.new(diffs2),
#           diffs12: Map.new(diffs12),
#           last: last,
#           rules_ver: if(real, do: Map.put(s.rules_ver, name, last), else: s.rules_ver),
#           # Ez biztosan uj itt.
#           ver_num: Map.put(ver_num, last, ver_num_diff),
#           last_mod1: Map.merge(s.last_mod1, mod1),
#           last_mod2: Map.merge(s.last_mod2, mod2),
#           last_mod12: Map.merge(s.last_mod12, mod12),
#           internal1: stage.internal1,
#           internal2: stage.internal2,
#           internal12: stage.internal12
#       }
#     else
#       if real, do: ver_num_bump(s, last, name, rule_time), else: s
#     end
#   end
#
#   @spec ver_num_bump(t, Integer.t(), String.t(), Integer.t()) :: t
#   def ver_num_bump(s, last, name, rule_time) do
#     # A rule felhozasa a mostanira.
#     ver_num = ver_num_delete(s.ver_num, rule_time)
#     ver_num = Map.update(ver_num, last, 1, fn x -> x + 1 end)
#     %{s | ver_num: ver_num, rules_ver: Map.put(s.rules_ver, name, last)}
#   end
#
#   @spec ver_num_delete(%{Integer.t() => Integer.t()}, Integer.t()) :: %{Integer.t() => Integer.t()}
#   def ver_num_delete(ver_num, rule_time) do
#     if rule_time == 0 do
#       ver_num
#     else
#       Map.get_and_update(ver_num, rule_time, fn current -> if(current == 1, do: :pop, else: {current, current - 1}) end) |> elem(1)
#     end
#   end
#
#   ######          ########   #######  ##      ##          ######
#   ##              ##     ## ##     ## ##  ##  ##              ##
#   ##              ##     ## ##     ## ##  ##  ##              ##
#   ##              ########  ##     ## ##  ##  ##              ##
#   ##              ##   ##   ##     ## ##  ##  ##              ##
#   ##              ##    ##  ##     ## ##  ##  ##              ##
#   ######          ##     ##  #######   ###  ###           ######
#
#   @spec individual_burst(t, Rule.burst()) :: t
#   def individual_burst(s, burst) do
#     s.rules |> Enum.filter(fn {_n, m} -> m.burst == burst end) |> Enum.map(fn {n, _m} -> n end) |> Enum.reduce(s, fn n, acc -> execute(acc, n) end)
#   end
#
#   @spec full_burst(t, Rule.burst()) :: t
#   def full_burst(s, burst) do
#     s = %{s | first: Map.put(s.first, burst, s.last)}
#     s = individual_burst(s, burst)
#     if s.last != s.first[burst], do: full_burst(s, burst), else: s
#   end
#
#   @spec cycle(t) :: t
#   def cycle(s) do
#     lst = s.msgqueue
#
#     s =
#       if lst != [] do
#         execute_step(
#           s,
#           "input",
#           0,
#           %{},
#           fn stage ->
#             Stage.put(stage, lst |> Enum.map(fn {map, key, val} -> {map, key, val, nil, nil, true} end))
#             # stage = Stage.put(stage, lst |> Enum.map(fn {map, key, val} -> {map, key, val, nil, nil, true} end))
#             # stage
#           end,
#           false
#         )
#       else
#         s
#       end
#
#     s = %{s | msgqueue: []}
#     s = full_burst(s, :cpu)
#     s = full_burst(s, :checkout)
#     s
#   end
#
#   ######          ######## ##     ## ######## ######## ########  ##    ##    ###    ##                ######
#   ##              ##        ##   ##     ##    ##       ##     ## ###   ##   ## ##   ##                    ##
#   ##              ##         ## ##      ##    ##       ##     ## ####  ##  ##   ##  ##                    ##
#   ##              ######      ###       ##    ######   ########  ## ## ## ##     ## ##                    ##
#   ##              ##         ## ##      ##    ##       ##   ##   ##  #### ######### ##                    ##
#   ##              ##        ##   ##     ##    ##       ##    ##  ##   ### ##     ## ##                    ##
#   ######          ######## ##     ##    ##    ######## ##     ## ##    ## ##     ## ########          ######
#
#   @spec install(
#           t,
#           name :: Mulmap.iden(),
#           binding :: Rule.binding_list(),
#           observe1 :: [Mulmap.iden()],
#           observe2 :: [Mulmap.iden()],
#           observe12 :: [{Mulmap.iden(), Mulmap.iden()}],
#           kernel :: Boolean.t(),
#           burst :: Rule.burst(),
#           function :: Rule.functionx(),
#           constructor :: Rule.functionx() | nil,
#           destructor :: Rule.functionx() | nil
#         ) :: t
#   def install(s, name, binding, observe1, observe2, observe12, kernel, burst, function, constructor \\ nil, destructor \\ nil) do
#     rule = Rule.constructor(name, binding, observe1, observe2, observe12, kernel, burst, function, constructor, destructor)
#     first = Map.put(s.first, burst, 0)
#     rules = Map.put(s.rules, name, rule)
#     s = %{s | first: first, rules: rules}
#     if constructor != nil, do: execute_step(s, name, 0, rule.binding, constructor, false), else: s
#   end
#
#   @spec uninstall(t, Mulmap.iden()) :: t
#   def uninstall(s, name) do
#     rules = s.rules
#     rule = Map.get(rules, name, nil)
#
#     if rule != nil do
#       rules = Map.delete(rules, name)
#       rules_ver = s.rules_ver
#       rule_time = Map.get(rules_ver, name, 0)
#       rules_ver = Map.delete(rules_ver, name)
#       ver_num = ver_num_delete(s.ver_num, rule_time)
#       s = %{s | rules: rules, rules_ver: rules_ver, ver_num: ver_num}
#       destructor = rule.destructor
#       if destructor != nil, do: execute_step(s, name, rule_time, rule.binding, destructor, false), else: s
#     else
#       s
#     end
#   end
#
#   @spec add_to_queue(t, {Mulmap.iden(), Mulmap.key(), Mulmap.scalar()}) :: t
#   def add_to_queue(s, msg), do: %{s | msgqueue: [msg | s.msgqueue]}
#
#   @spec add_to_queue(t, Mulmap.iden(), Mulmap.key(), Mulmap.scalar()) :: t
#   def add_to_queue(s, iden, key, scalar), do: %{s | msgqueue: [{iden, key, scalar} | s.msgqueue]}
#
#   @spec set_pid(t, String.t()) :: t
#   def set_pid(s, pid), do: %{s | pid: pid}
#
#   @spec checkout_advanced(t) :: Boolean.t()
#   def checkout_advanced(s), do: s.last > s.first[:checkout]
#
#   # defmodule
# end

# alias Ggesygan.Fsm.Escdal5
# alias ADB.Store
# alias ADB.Stage
#
# defmodule Escdal5 do
#   use ADB.Srv
#
#   @spec start_link(atom) :: GenServer.on_start()
#   def start_link(name), do: GenServer.start_link(__MODULE__, [name], name: name)
#
#   # @spec init_callback(Store.t(), any) :: {:ok, Store.t()} | {:stop, any}
#   def init_callback(s, [name]) do
#     s = Store.set_pid(s, "#{name}-#{s.pid}")
#     pid = s.pid
#     Logger.info("| #{pid} | starting |")
#
#     # s =
#     #   Store.install(s, "lock_in", [{"lock", "lock"}, {"lock_in", "lock_in"}, {"lock_out", "lock_out"}], ["lock_in"], [], [], false, :cpu, fn stage ->
#     #     lock = Stage.getmap1(stage, "lock")
#     #     rq = Stage.getdiff1(stage, "lock_in")
#     #     rq |> Enum.map(fn {pd, {_, list}} ->
#     #       list |> Enum.map(fn x ->
#     #         if Map.get(lock, x) == nil do
#     #         else
#     #         end
#     #       end)
#     #     end)
#     #   end)
#
#     s =
#       Store.install(s, "register", [{"ciregister", "ciregister"}, {"sessions", "sessions"}], ["ciregister"], [], [], false, :cpu, fn stage ->
#         nsessions = stage.binding["sessions"]
#         nciregister = stage.binding["ciregister"]
#         rq = Stage.getdiff1(stage, nciregister)
#
#         operations =
#           rq
#           |> Enum.map(fn {iam, {_, payload}} ->
#             case payload do
#               false -> {nsessions, iam, :undefined, nil, :iden, false}
#               seq -> {nsessions, iam, seq, nil, :iden, false}
#             end
#           end)
#
#         stage = Stage.put(stage, operations)
#         operations = rq |> Enum.map(fn {iam, _payload} -> {nciregister, iam, :undefined, nil, nil, false} end)
#         stage = Stage.put(stage, operations)
#         stage
#       end)
#
#     # s =
#     #   Store.install(s, "state", [{"sessions", "sessions"}, {"states", "states"}], ["sessions"], [], [], false, :cpu, fn stage ->
#     #     nsessions = stage.binding["sessions"]
#     #     dsessions = Stage.getdiff1(stage, nsessions)
#     #     nstates = stage.binding["states"]
#     #     mstates = Stage.getmap1(stage, nstates, %{})
#     #     seq = Map.get(Stage.getmap1(stage, "eq", %{}), "seq", 0)
#     #
#     #     dsessions |> Enum.map(fn {iam, {old, new}} ->
#     #       vector = Map.get(nstates, iam)
#     #       if vector == nil
#     #     end)
#     #
#     #     stage
#     #   end)
#
#     s =
#       Store.install(s, "monitor", [{"sessions", "sessions"}], ["sessions"], [], [], false, :checkout, fn stage ->
#         nsessions = stage.binding["sessions"]
#         dsessions = Stage.getdiff1(stage, nsessions)
#
#         dsessions
#         |> Enum.each(fn {iam, {old, new}} ->
#           Logger.info("| #{pid} | registered | #{iam} | #{inspect(old)} | -> | #{inspect(new)} |")
#         end)
#
#         stage
#       end)
#
#     {:ok, s}
#   end
#
#   # @spec handle_info_callback(Store.t(), any) :: Store.t()
#   def handle_info_callback(s, msg) do
#     case msg do
#       {"register", iam, seq} ->
#         Store.add_to_queue(s, "ciregister", iam, seq)
#
#       {"unregister", iam} ->
#         Store.add_to_queue(s, "ciregister", iam, false)
#
#       # {"lock", pd, {iam, lst}} -> Store.add_to_queue(s, "lock_in", pd, {"lock", iam, lst})
#       # {"unlock", pd, {iam, lst}} -> Store.add_to_queue(s, "lock_in", pd, {"unlock", iam, lst})
#       _ ->
#         s
#     end
#   end
# end
