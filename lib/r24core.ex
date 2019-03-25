alias R24Core
alias ADB.Store
alias ADB.Stage
alias ADB.Mlmap

defmodule R24Core do
  @vsn "0.1.0"
  use ADB.Srv
  require Util

  @moduledoc """

  ```

  # Tablak
  diffs -> iam -> seq -> adat a kikuldott seq-k es adatok
  origs -> iam -> seq -> a megfelelo origok a szureshez
  sessions -> iam -> seq utolso VETT seq, illetve az elo session-ok
  maxseq -> iam -> seq az utolso KULDOTT seq
  eq -> seq az utolso ervenyes seq
  store az osszes cucc, amit kuldeni kell. Potencialisan szurni kell!

  # Input
  - ciregister -> iam -> seq vagy false
  - cidata -> iam -> node -> nodedata
  - cilock -> iam -> node -> true/false

  # A trackeltek (amik bekerulnek a store-ba)
  - locks -> node -> iam
  - locks_inv -> iam -> node -> true
  - data -> node -> nodestruct

  orig -diff-> start -stage-> internal
  ```

  TODO data-keresek
  TODO Tenyleges keresek kezelese, ti. kereshez mindig menjen valasz is, ne csak a diff.
  TODO adatbazisbol felolvasas-visszairas.
  TODO
  TODO jogosultsatok.

  `@vsn "#{@vsn}"`
  """

  @spec start_link(atom) :: GenServer.on_start()
  def start_link(name), do: GenServer.start_link(__MODULE__, [name], name: name)

  # @spec handle_info_callback(Store.t(), any) :: Store.t()
  def handle_info_callback(s, msg) do
    case msg do
      ["register", iam, seq] ->
        Store.add_to_queue(s, ["ciregister", iam], seq)

      ["unregister", iam, _seq] ->
        Store.add_to_queue(s, ["ciregister", iam], false)

      ["lock", iam, seq, lst] ->
        s = Store.add_to_queue(s, ["ciregister", iam], seq)
        lst |> Enum.reduce(s, fn x, s -> Store.add_to_queue(s, ["cilock", iam, x], true) end)

      ["data", iam, seq, nodeinfo] ->
        s = Store.add_to_queue(s, ["ciregister", iam], seq)
        Store.add_to_queue(s, ["cidata", iam], nodeinfo)

      ["unlock", iam, seq, lst] ->
        s = Store.add_to_queue(s, ["ciregister", iam], seq)
        lst |> Enum.reduce(s, fn x, s -> Store.add_to_queue(s, ["cilock", iam, x], false) end)

      _ ->
        s
    end
  end

  # @spec init_callback(Store.t(), any) :: {:ok, Store.t()} | {:stop, any}
  def init_callback(s, [name]) do
    s = Store.set_pid(s, "#{name}-#{s.pid}")
    pid = s.pid
    Logger.info("| #{pid} | starting |")

    ######            #####     #####            ######
    ##               ##   ##   ##   ##               ##
    ##              ##     ## ##     ##              ##
    ##              ##     ## ##     ##              ##
    ##              ##     ## ##     ##              ##
    ##               ##   ##   ##   ##               ##
    ######            #####     #####            ######

    ######          ########  ########  ######   ####  ######  ######## ######## ########           ######
    ##              ##     ## ##       ##    ##   ##  ##    ##    ##    ##       ##     ##              ##
    ##              ##     ## ##       ##         ##  ##          ##    ##       ##     ##              ##
    ##              ########  ######   ##   ####  ##   ######     ##    ######   ########               ##
    ##              ##   ##   ##       ##    ##   ##        ##    ##    ##       ##   ##                ##
    ##              ##    ##  ##       ##    ##   ##  ##    ##    ##    ##       ##    ##               ##
    ######          ##     ## ########  ######   ####  ######     ##    ######## ##     ##          ######

    s =
      Store.install(s, "01register", [{"ciregister", "ciregister"}, {"sessions", "sessions"}], ["ciregister"], [], [], false, :cpu, fn stage ->
        rq = Stage.get(stage, ["ciregister"], %{})
        iseq = Stage.get(stage, ["eq", "seq"], 0)

        operations =
          rq
          |> Enum.map(fn {iam, payload} ->
            case payload do
              false ->
                {["sessions", iam], :undefined, nil}

              seq when seq > iseq ->
                Logger.warn("| #{pid} | 00register | iam | #{iam} | seq | #{seq} | greater_than | #{iseq} |")
                :bump

              seq ->
                {["sessions", iam], seq, nil}
            end
          end)
          |> Enum.filter(fn x -> x != :bump end)

        operations2 = rq |> Enum.map(fn {iam, _payload} -> {["ciregister", iam], :undefined, nil} end)

        stage = Stage.put(stage, operations ++ operations2)
        # Logger.warn("register: #{inspect(stage)}")
        stage
      end)

    ######          ##        #######   ######  ##    ##          ######
    ##              ##       ##     ## ##    ## ##   ##               ##
    ##              ##       ##     ## ##       ##  ##                ##
    ##              ##       ##     ## ##       #####                 ##
    ##              ##       ##     ## ##       ##  ##                ##
    ##              ##       ##     ## ##    ## ##   ##               ##
    ######          ########  #######   ######  ##    ##          ######

    s =
      Store.install(s, "02lock", [{"cilock", "cilock"}, {"sessions", "sessions"}], ["cilock", "sessions"], [], [], false, :cpu, fn stage ->
        rq = Stage.get(stage, ["cilock"], %{})
        ilocks = Stage.get(stage, ["locks"], %{})
        ilocks_inv = Stage.get(stage, ["locks_inv"], %{})
        dsessions = Stage.getm(stage, :diff1, ["sessions"], %{})
        idata = Stage.get(stage, ["data"], %{})

        # Explicit lock-keresek
        operations =
          rq
          |> Enum.map(fn {iam, mp} ->
            lockset = mp |> Enum.filter(fn {_node, dir} -> dir end) |> Enum.map(fn {node, _} -> node end)
            unlockset = mp |> Enum.filter(fn {_node, dir} -> !dir end) |> Enum.map(fn {node, _} -> node end)

            lockable =
              lockset
              |> Enum.reduce_while(true, fn node, _acc ->
                case Map.get(ilocks, node) do
                  nil ->
                    if Map.get(idata, node) == nil do
                      Logger.warn("| #{pid} | 00lock | iam | #{iam} | node | #{node} | LOCK_FAILED_NONEXISTENT_NODE |")
                      {:halt, false}
                    else
                      {:cont, true}
                    end

                  ^iam ->
                    {:cont, true}

                  owner ->
                    Logger.warn("| #{pid} | 00lock | iam | #{iam} | node | #{node} | owner | #{owner} | LOCK_FAILED_LOCKED_BY_OTHER |")
                    {:halt, false}
                end
              end)

            lockset =
              if lockable do
                [lockset |> Enum.map(fn node -> {["locks", node], iam, nil} end), lockset |> Enum.map(fn node -> {["locks_inv", iam, node], true, nil} end)]
              else
                []
              end

            unlockset =
              unlockset
              |> Enum.map(fn node ->
                case Map.get(ilocks, node) do
                  nil ->
                    Logger.warn("| #{pid} | 00lock | iam | #{iam} | node | #{node} | UNLOCK_FAIL_NO_OWNER |")
                    :bump

                  ^iam ->
                    [{["locks", node], :undefined, nil}, {["locks_inv", iam, node], :undefined, nil}]

                  owner ->
                    Logger.warn("| #{pid} | 00lock | iam | #{iam} | node | #{node} | owner | #{owner} | UNLOCK_FAIL_OTHER_OWNER |")
                    :bump
                end
              end)
              |> Enum.filter(fn x -> x != :bump end)

            lockset ++ unlockset
          end)

        operations2 = rq |> Enum.map(fn {iam, _payload} -> {["cilock", iam], :undefined, nil} end)

        # A kiregisztraltak torlese
        operations3 =
          dsessions
          |> Enum.map(fn {iam, seq} ->
            Util.wife :bump, seq == :undefined do
              Map.get(ilocks_inv, iam, %{}) |> Enum.map(fn {node, _} -> [{["locks", node], :undefined, nil}, {["locks_inv", iam, node], :undefined, nil}] end)
            end
          end)
          |> Enum.filter(fn x -> x != :bump end)

        operations = [operations2, operations3 | operations]
        operations = List.flatten(operations)

        stage = Stage.put(stage, operations)
        stage
      end)

    ######          ########     ###    ########    ###             ######
    ##              ##     ##   ## ##      ##      ## ##                ##
    ##              ##     ##  ##   ##     ##     ##   ##               ##
    ##              ##     ## ##     ##    ##    ##     ##              ##
    ##              ##     ## #########    ##    #########              ##
    ##              ##     ## ##     ##    ##    ##     ##              ##
    ######          ########  ##     ##    ##    ##     ##          ######

    s =
      Store.install(s, "03data", [{"cidata", "cidata"}], ["cidata"], [], [], false, :cpu, fn stage ->
        rq = Stage.get(stage, ["cidata"], %{})
        idata = Stage.get(stage, ["data"], %{})
        ilocks = Stage.get(stage, ["locks"], %{})

        # Explicit lock-keresek
        operations =
          rq
          |> Enum.map(fn {iam, nodedata} ->
            node = nodedata["id"]

            if node != nil do
              case Map.get(idata, node) do
                nil ->
                  # Insert (egyben lock is!)
                  [{["data", node], nodedata, nil}, {["locks", node], iam, nil}, {["locks_inv", iam, node], true, nil}]

                _ ->
                  # Update
                  case Map.get(ilocks, node) do
                    nil ->
                      Logger.warn("| #{pid} | data | iam | #{iam} | node | #{node} | NO_LOCK |")
                      :bump

                    ^iam ->
                      # Succ mod.
                      {["data", node], nodedata, nil}

                    owner ->
                      Logger.warn("| #{pid} | data | iam | #{iam} | node | #{node} | owner | #{owner} | LOCK_FAILED |")
                      :bump
                  end
              end
            else
              Logger.warn("| #{pid} | data | iam | #{iam} | nodedata | MISSING_ID |")
              :bump
            end
          end)
          |> Enum.filter(fn x -> x != :bump end)

        operations2 = rq |> Enum.map(fn {iam, _payload} -> {["cidata", iam], :undefined, nil} end)

        operations = [operations2 | operations]
        operations = List.flatten(operations)

        stage = Stage.put(stage, operations)
        stage
      end)

    ######          ########   #####            ######
    ##              ##    ##  ##   ##               ##
    ##                  ##   ##     ##              ##
    ##                 ##    ##     ##              ##
    ##                ##     ##     ##              ##
    ##                ##      ##   ##               ##
    ######            ##       #####            ######

    ######           ######  ########  #######  ########  ########          ######
    ##              ##    ##    ##    ##     ## ##     ## ##                    ##
    ##              ##          ##    ##     ## ##     ## ##                    ##
    ##               ######     ##    ##     ## ########  ######                ##
    ##                    ##    ##    ##     ## ##   ##   ##                    ##
    ##              ##    ##    ##    ##     ## ##    ##  ##                    ##
    ######           ######     ##     #######  ##     ## ########          ######

    s =
      Store.install(s, "71store", [{"locks", "locks"}, {"data", "data"}], ["locks", "data"], [], [], false, :cpu, fn stage ->
        iseq = Stage.get(stage, ["eq", "seq"], 0)
        oseq = Stage.getm(stage, :orig1, ["eq", "seq"])
        dlocks = Stage.getm(stage, :diff1, ["locks"], %{})
        ddata = Stage.getm(stage, :diff1, ["data"], %{})

        # Ez - sajnos - azert kell igy, mert ha felszedjuk adatbazisbol, nem kell uj verziot dobni.
        iseq = if oseq == :undefined, do: iseq, else: iseq + 1

        stage = Stage.put(stage, ["eq", "seq"], iseq, :iden)
        dstore = Mlmap.update(%{}, ["eq", "seq"], iseq)
        dstore = if dlocks == %{}, do: dstore, else: Mlmap.update(dstore, ["locks"], dlocks)
        dstore = if ddata == %{}, do: dstore, else: Mlmap.update(dstore, ["data"], ddata)
        stage = Stage.merge(stage, ["store"], dstore)

        stage
      end)

    ######           #######    #####            ######
    ##              ##     ##  ##   ##               ##
    ##              ##     ## ##     ##              ##
    ##               #######  ##     ##              ##
    ##              ##     ## ##     ##              ##
    ##              ##     ##  ##   ##               ##
    ######           #######    #####            ######

    ######          ########  #### ######## ########         ######## #### ##       ######## ######## ########           ######
    ##              ##     ##  ##  ##       ##               ##        ##  ##          ##    ##       ##     ##              ##
    ##              ##     ##  ##  ##       ##               ##        ##  ##          ##    ##       ##     ##              ##
    ##              ##     ##  ##  ######   ######   ####### ######    ##  ##          ##    ######   ########               ##
    ##              ##     ##  ##  ##       ##               ##        ##  ##          ##    ##       ##   ##                ##
    ##              ##     ##  ##  ##       ##               ##        ##  ##          ##    ##       ##    ##               ##
    ######          ########  #### ##       ##               ##       #### ########    ##    ######## ##     ##          ######

    s =
      Store.install(s, "81diff-filter", [{"sessions", "sessions"}], ["sessions"], [], [], false, :cpu, fn stage ->
        dsessions = Stage.getm(stage, :diff1, ["sessions"], %{})
        sdiffs = Stage.getm(stage, :start1, ["diffs"], %{})
        sorigs = Stage.getm(stage, :start1, ["origs"], %{})
        istore = Stage.get(stage, ["store"], %{})
        iseq = Stage.get(stage, ["eq", "seq"], 0)

        # Logger.warn("| #{pid} | diff-filter | stage_before | #{inspect(stage, pretty: true)} |")

        stage =
          dsessions
          |> Enum.reduce(stage, fn {iam, new}, stage ->
            st =
              case new do
                :undefined ->
                  Stage.put(stage, [{["maxseq", iam], :undefined, nil}, {["origs", iam], :undefined, nil}, {["diffs", iam], :undefined, nil}])

                0 ->
                  :bump

                _ ->
                  mp1 = Map.get(sdiffs, iam)

                  # Valami regi, nullanak vesszuk.
                  Util.wife :bump, mp1 != nil do
                    # Ha tul korai, akkor nulla.
                    Util.wife :bump, Map.get(mp1, new) != nil do
                      mp2 = Map.get(sorigs, iam)
                      mp1 = mp1 |> Enum.filter(fn {seq, _} -> seq >= new end) |> Map.new()
                      mp2 = mp2 |> Enum.filter(fn {seq, _} -> seq >= new end) |> Map.new()
                      Stage.put(stage, [{["diffs", iam], mp1, nil}, {["origs", iam], mp2, nil}])
                    end
                  end
              end

            Util.wife st, st == :bump do
              Stage.put(stage, [
                {["sessions", iam], 0, nil},
                {["maxseq", iam], iseq, nil},
                {["origs", iam], %{0 => %{}, iseq => istore}, nil},
                {["diffs", iam], %{0 => istore, iseq => %{}}, nil}
              ])
            end
          end)

        # Logger.warn("| #{pid} | diff-filter | stage_after | #{inspect(stage, pretty: true)} |")
        stage
      end)

    ######          ########  #### ######## ######## ##     ## ########  ########     ###    ######## ########          ######
    ##              ##     ##  ##  ##       ##       ##     ## ##     ## ##     ##   ## ##      ##    ##                    ##
    ##              ##     ##  ##  ##       ##       ##     ## ##     ## ##     ##  ##   ##     ##    ##                    ##
    ##              ##     ##  ##  ######   ######   ##     ## ########  ##     ## ##     ##    ##    ######                ##
    ##              ##     ##  ##  ##       ##       ##     ## ##        ##     ## #########    ##    ##                    ##
    ##              ##     ##  ##  ##       ##       ##     ## ##        ##     ## ##     ##    ##    ##                    ##
    ######          ########  #### ##       ##        #######  ##        ########  ##     ##    ##    ########          ######

    s =
      Store.install(s, "82diffupdate", [{"eq", "eq"}, {"seq", "seq"}], [], [], [{"eq", "seq"}], false, :cpu, fn stage ->
        idiffs = Stage.get(stage, ["diffs"], %{})
        iorigs = Stage.get(stage, ["origs"], %{})
        imaxseq = Stage.get(stage, ["maxseq"], %{})
        dstore = Stage.getm(stage, :diff1, ["store"], %{})
        istore = Stage.get(stage, ["store"], %{})
        iseq = Stage.get(stage, ["eq", "seq"], 0)

        stage =
          imaxseq
          |> Enum.reduce(stage, fn {iam, seq}, stage ->
            Util.wife stage, seq < iseq do
              mp1 = Map.get(idiffs, iam)
              mp2 = Map.get(iorigs, iam)

              # Itt elvileg szurni kene dstore-t!
              mp1 =
                mp1
                |> Enum.map(fn {seq, di} ->
                  res = Mlmap.merge(di, dstore) |> Mlmap.filter(Map.get(mp2, seq))
                  {seq, res}
                  # {seq, Mlmap.merge(di, dstore) |> Mlmap.filter(Map.get(mp2, seq))}
                end)
                |> Map.new()

              mp1 = Map.put(mp1, iseq, %{})
              mp2 = Map.put(mp2, iseq, istore)
              # Logger.warn("| pid | diffupdate | iam | #{iam} | iseq | #{iseq} | mp1 | #{inspect mp1} | mp2 | #{inspect mp2} |")
              Stage.put(stage, [{["diffs", iam], mp1, nil}, {["origs", iam], mp2, nil}, {["maxseq", iam], iseq, nil}])
            end
          end)

        # Logger.warn("| #{pid} | diffupdate | #{inspect(stage, pretty: true)} |")
        stage
      end)

    ######           #######    #####            ######
    ##              ##     ##  ##   ##               ##
    ##              ##     ## ##     ##              ##
    ##               ######## ##     ##              ##
    ##                     ## ##     ##              ##
    ##              ##     ##  ##   ##               ##
    ######           #######    #####            ######

    ######          ########  #### ######## ######## ########  ######## ##       #### ##     ## ######## ########           ######
    ##              ##     ##  ##  ##       ##       ##     ## ##       ##        ##  ##     ## ##       ##     ##              ##
    ##              ##     ##  ##  ##       ##       ##     ## ##       ##        ##  ##     ## ##       ##     ##              ##
    ##              ##     ##  ##  ######   ######   ##     ## ######   ##        ##  ##     ## ######   ########               ##
    ##              ##     ##  ##  ##       ##       ##     ## ##       ##        ##   ##   ##  ##       ##   ##                ##
    ##              ##     ##  ##  ##       ##       ##     ## ##       ##        ##    ## ##   ##       ##    ##               ##
    ######          ########  #### ##       ##       ########  ######## ######## ####    ###    ######## ##     ##          ######

    s =
      Store.install(s, "91diffdeliver", [{"sessions", "sessions"}, {"maxseq", "maxseq"}], ["sessions", "maxseq"], [], [], false, :checkout, fn stage ->
        idiffs = Stage.get(stage, ["diffs"], %{})
        isessions = Stage.get(stage, ["sessions"], %{})
        dsessions = Stage.getm(stage, :diff1, ["sessions"], %{})
        dmaxseq = Stage.getm(stage, :diff1, ["maxseq"], %{})
        imaxseq = Stage.get(stage, ["maxseq"], %{})
        combined = Map.merge(dsessions, dmaxseq)
        # iseq = Stage.get(stage, ["eq", "seq"], 0)

        combined
        |> Enum.each(fn {iam, _} ->
          if dsessions[iam] == :undefined do
            Logger.info("| #{pid} | 91diffdeliver | #{iam} | KATAPULT |")
          else
            old = isessions[iam]
            new = imaxseq[iam]
            packet = Mlmap.get(idiffs, [iam, old])
            # Ilyenkor hianyzik belole ez az info.
            packet = if new == old, do: Mlmap.update(packet, ["eq", "seq"], new), else: packet
            packet = Mlmap.update(packet, ["eq", "old_seq"], old)
            Logger.info("| #{pid} | 91diffdeliver | #{iam} | => | #{inspect(packet)} |")
          end
        end)

        stage
      end)

    {:ok, s}

    ######          ########  ########   ######     ###    ##     ## ########          ######
    ##              ##     ## ##     ## ##    ##   ## ##   ##     ## ##                    ##
    ##              ##     ## ##     ## ##        ##   ##  ##     ## ##                    ##
    ##              ##     ## ########   ######  ##     ## ##     ## ######                ##
    ##              ##     ## ##     ##       ## #########  ##   ##  ##                    ##
    ##              ##     ## ##     ## ##    ## ##     ##   ## ##   ##                    ##
    ######          ########  ########   ######  ##     ##    ###    ########          ######

    s =
      Store.install(
        s,
        "92dbsave",
        [{"store", "store"}, {"eq", "eq"}, {"seq", "seq"}],
        ["store", "eq", "seq"],
        [],
        [],
        false,
        :checkout,
        fn stage ->
          oseq = Stage.getm(stage, :orig1, ["eq", "seq"])

          stage =
            if oseq != :undefined do
              # lst = Stage.getm(stage, :diff1, ["data"], %{}) |> Enum.map(fn {node, content} -> {:data, node, content} end)
              # lst = [{:eq, "seq", iseq} | lst]
              Logger.info("| #{pid} | DBSAVE |")
              stage
            else
              stage
            end

          stage
        end,
        fn stage ->
          lst = data() |> Enum.map(fn {node, content} -> {["data", node], content, nil} end)
          stage = Stage.put(stage, lst)
          stage = Stage.put(stage, ["eq", "seq"], 1)

          stage
        end
      )

    {:ok, s}
  end

  ######          ########     ###    ########     ###     ######  ######## ########         ########  ########           ######
  ##              ##     ##   ## ##   ##     ##   ## ##   ##    ##      ##     ##            ##     ## ##     ##              ##
  ##              ##     ##  ##   ##  ##     ##  ##   ##  ##           ##      ##            ##     ## ##     ##              ##
  ##              ########  ##     ## ########  ##     ##  ######     ##       ##    ####### ##     ## ########               ##
  ##              ##        ######### ##   ##   #########       ##   ##        ##            ##     ## ##     ##              ##
  ##              ##        ##     ## ##    ##  ##     ## ##    ##  ##         ##            ##     ## ##     ##              ##
  ######          ##        ##     ## ##     ## ##     ##  ######  ########    ##            ########  ########           ######

  def data() do
    %{
      "10001" => %{
        "children" => ["10002", "14107", "14146"],
        "ext" => %{"config" => 42, "tag_id" => "161557"},
        "id" => "10001",
        "status" => 1,
        "sub_type" => "",
        "title" => "RTL24",
        "type" => "show",
        "visible" => 1
      },
      "14107" => %{
        "children" => [],
        "ext" => %{"url" => "210", "parent_id" => "10001"},
        "id" => "14107",
        "status" => 1,
        "sub_type" => "",
        "title" => "XF - Pepsi kampány",
        "type" => "asset",
        "visible" => 1
      },
      "14146" => %{
        "children" => [],
        "ext" => %{"url" => "212", "parent_id" => "10001"},
        "id" => "14146",
        "status" => 1,
        "sub_type" => "",
        "title" => "XF - Pepsi kampány",
        "type" => "asset",
        "visible" => 1
      },
      "10000" => %{
        "children" => ["10001"],
        "ext" => nil,
        "id" => "10000",
        "status" => 1,
        "sub_type" => "",
        "title" => "RTL24 Application",
        "type" => "application",
        "visible" => 1
      },
      "10002" => %{
        "children" => [],
        "ext" => %{"asset_id" => nil},
        "id" => "10002",
        "status" => 1,
        "sub_type" => "menu_item_newsfeed",
        "title" => "Top Hírek",
        "type" => "menu_item",
        "visible" => 1
      }
    }
  end

  # def data() do
  #   %{
  #     "14402" => %{
  #       "children" => [],
  #       "ext" => %{"asset_1" => "166", "orientation" => "horizontal"},
  #       "id" => "14402",
  #       "status" => 1,
  #       "sub_type" => "vote_option_imgtext",
  #       "title" => "Zsuzsu",
  #       "type" => "vote_option",
  #       "visible" => 1
  #     },
  #     "13733" => %{
  #       "children" => [],
  #       "ext" => %{"asset_id" => nil},
  #       "id" => "13733",
  #       "status" => 0,
  #       "sub_type" => "menu_item_vote",
  #       "title" => "Szavazás-1",
  #       "type" => "menu_item",
  #       "visible" => 0
  #     },
  #     "14036" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "164", "parent_id" => "14019"},
  #       "id" => "14036",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Tina",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14054" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "182", "parent_id" => "14019"},
  #       "id" => "14054",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Kiv_Zsuzsu",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "10001" => %{
  #       "children" => ["10002", "14107", "14146"],
  #       "ext" => %{"config" => 42, "tag_id" => "161557"},
  #       "id" => "10001",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "RTL24",
  #       "type" => "show",
  #       "visible" => 1
  #     },
  #     "14073" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "189", "parent_id" => "14019"},
  #       "id" => "14073",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Kih_Geri",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14053" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "181", "parent_id" => "14019"},
  #       "id" => "14053",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Kiv_Vivien",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14024" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "152", "parent_id" => "14019"},
  #       "id" => "14024",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Cintike",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14401" => %{
  #       "children" => [],
  #       "ext" => %{"asset_1" => "157", "orientation" => "horizontal"},
  #       "id" => "14401",
  #       "status" => 1,
  #       "sub_type" => "vote_option_imgtext",
  #       "title" => "Hunor",
  #       "type" => "vote_option",
  #       "visible" => 1
  #     },
  #     "14052" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "180", "parent_id" => "14019"},
  #       "id" => "14052",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Kiv_Tina",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14079" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "195", "parent_id" => "14019"},
  #       "id" => "14079",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Kih_Reni",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14085" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "201", "parent_id" => "14063"},
  #       "id" => "14085",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Kovács Pál",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14314" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "223", "parent_id" => "14302"},
  #       "id" => "14314",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "varga_sarolta",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14040" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "168", "parent_id" => "14019"},
  #       "id" => "14040",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Kiv_Cintike",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14092" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "208", "parent_id" => "14063"},
  #       "id" => "14092",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Urbanovics Vivien",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14072" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "188", "parent_id" => "14019"},
  #       "id" => "14072",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Kih_Era",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14304" => %{
  #       "children" => [],
  #       "ext" => %{"asset_id" => nil},
  #       "id" => "14304",
  #       "status" => 1,
  #       "sub_type" => "menu_item_vote",
  #       "title" => "Szavazás",
  #       "type" => "menu_item",
  #       "visible" => 1
  #     },
  #     "14078" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "194", "parent_id" => "14019"},
  #       "id" => "14078",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Kih_Radics",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14056" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "183", "parent_id" => "14019"},
  #       "id" => "14056",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "dummy1",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14070" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "186", "parent_id" => "14019"},
  #       "id" => "14070",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Kih_Adri",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14086" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "202", "parent_id" => "14063"},
  #       "id" => "14086",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Ölveti László",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14302" => %{
  #       "children" => ["14303", "14304", "14305", "14306", "14307", "14308", "14309", "14310", "14311", "14312", "14313", "14314"],
  #       "ext" => %{"tag_id" => "179055"},
  #       "id" => "14302",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Az év embere 2018",
  #       "type" => "show",
  #       "visible" => 1
  #     },
  #     "14196" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "213", "parent_id" => "14019"},
  #       "id" => "14196",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "lazacdummy",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14065" => %{
  #       "children" => [],
  #       "ext" => %{"asset_id" => nil},
  #       "id" => "14065",
  #       "status" => 1,
  #       "sub_type" => "menu_item_vote",
  #       "title" => "Szavazás",
  #       "type" => "menu_item",
  #       "visible" => 1
  #     },
  #     "14081" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "197", "parent_id" => "14019"},
  #       "id" => "14081",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Kih_Vivien",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "13758" => %{
  #       "children" => [],
  #       "ext" => %{"asset_id" => nil},
  #       "id" => "13758",
  #       "status" => 0,
  #       "sub_type" => "menu_item_vote",
  #       "title" => "Szavazás-5",
  #       "type" => "menu_item",
  #       "visible" => 0
  #     },
  #     "14311" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "220", "parent_id" => "14302"},
  #       "id" => "14311",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "meszaros_marta",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14392" => %{
  #       "children" => [],
  #       "ext" => %{"asset_1" => "157", "orientation" => "horizontal"},
  #       "id" => "14392",
  #       "status" => 1,
  #       "sub_type" => "vote_option_imgtext",
  #       "title" => "Hunor",
  #       "type" => "vote_option",
  #       "visible" => 1
  #     },
  #     "14390" => %{
  #       "children" => ["14391", "14392", "14393"],
  #       "ext" => %{
  #         "asset_1" => nil,
  #         "asset_2" => nil,
  #         "changeable" => 0,
  #         "deletable" => 0,
  #         "max_select" => 1,
  #         "min_select" => 1,
  #         "multiple_select" => 0
  #       },
  #       "id" => "14390",
  #       "status" => 1,
  #       "sub_type" => "vote_multi",
  #       "title" => "KIT HÍVNÁNAK KI ZSUZSU HELYÉBEN?",
  #       "type" => "vote",
  #       "visible" => 1
  #     },
  #     "14033" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "161", "parent_id" => "14019"},
  #       "id" => "14033",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Renátó",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14026" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "154", "parent_id" => "14019"},
  #       "id" => "14026",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Era",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14088" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "204", "parent_id" => "14063"},
  #       "id" => "14088",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Stolen Beat",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14021" => %{
  #       "children" => ["14399"],
  #       "ext" => %{"asset_id" => nil},
  #       "id" => "14021",
  #       "status" => 1,
  #       "sub_type" => "menu_item_vote",
  #       "title" => "Szavazás",
  #       "type" => "menu_item",
  #       "visible" => 1
  #     },
  #     "14039" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "167", "parent_id" => "14019"},
  #       "id" => "14039",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Kiv_Adri",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14041" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "169", "parent_id" => "14019"},
  #       "id" => "14041",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Kiv_Csoki",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14051" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "179", "parent_id" => "14019"},
  #       "id" => "14051",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Kiv_Roli",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14393" => %{
  #       "children" => [],
  #       "ext" => %{"asset_1" => "163", "orientation" => "horizontal"},
  #       "id" => "14393",
  #       "status" => 1,
  #       "sub_type" => "vote_option_imgtext",
  #       "title" => "Roli",
  #       "type" => "vote_option",
  #       "visible" => 1
  #     },
  #     "14064" => %{
  #       "children" => [],
  #       "ext" => %{"asset_id" => nil},
  #       "id" => "14064",
  #       "status" => 1,
  #       "sub_type" => "menu_item_newsfeed",
  #       "title" => "Pillanatok",
  #       "type" => "menu_item",
  #       "visible" => 1
  #     },
  #     "14312" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "221", "parent_id" => "14302"},
  #       "id" => "14312",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "noar",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14074" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "190", "parent_id" => "14019"},
  #       "id" => "14074",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Kih_Ginu",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14035" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "163", "parent_id" => "14019"},
  #       "id" => "14035",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Roli",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14062" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "185", "parent_id" => "14019"},
  #       "id" => "14062",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Kih_dummy",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14400" => %{
  #       "children" => ["14401", "14402"],
  #       "ext" => %{
  #         "asset_1" => nil,
  #         "asset_2" => nil,
  #         "changeable" => 0,
  #         "deletable" => 0,
  #         "max_select" => 1,
  #         "min_select" => 1,
  #         "multiple_select" => 0
  #       },
  #       "id" => "14400",
  #       "status" => 1,
  #       "sub_type" => "vote_multi",
  #       "title" => "Finálé 2.",
  #       "type" => "vote",
  #       "visible" => 1
  #     },
  #     "14107" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "210", "parent_id" => "10001"},
  #       "id" => "14107",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "XF - Pepsi kampány",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14045" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "173", "parent_id" => "14019"},
  #       "id" => "14045",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Kiv_Hunor",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14309" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "218", "parent_id" => "14302"},
  #       "id" => "14309",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "kurucsai_szabolcs",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14038" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "166", "parent_id" => "14019"},
  #       "id" => "14038",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Zsuzsu",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14146" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "212", "parent_id" => "10001"},
  #       "id" => "14146",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "XF - Pepsi kampány",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14032" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "160", "parent_id" => "14019"},
  #       "id" => "14032",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Radics",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14082" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "198", "parent_id" => "14019"},
  #       "id" => "14082",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Kih_Zsuzsu",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14020" => %{
  #       "children" => [],
  #       "ext" => %{"asset_id" => nil},
  #       "id" => "14020",
  #       "status" => 1,
  #       "sub_type" => "menu_item_newsfeed",
  #       "title" => "Pillanatok",
  #       "type" => "menu_item",
  #       "visible" => 1
  #     },
  #     "14023" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "151", "parent_id" => "14019"},
  #       "id" => "14023",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Adri",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14050" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "178", "parent_id" => "14019"},
  #       "id" => "14050",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Kiv_Reni",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14019" => %{
  #       "children" => [
  #         "14020",
  #         "14021",
  #         "14022",
  #         "14023",
  #         "14024",
  #         "14025",
  #         "14026",
  #         "14027",
  #         "14028",
  #         "14029",
  #         "14030",
  #         "14031",
  #         "14032",
  #         "14033",
  #         "14034",
  #         "14035",
  #         "14036",
  #         "14037",
  #         "14038",
  #         "14039",
  #         "14040",
  #         "14041",
  #         "14042",
  #         "14043",
  #         "14044",
  #         "14045",
  #         "14046",
  #         "14047",
  #         "14048",
  #         "14049",
  #         "14050",
  #         "14051",
  #         "14052",
  #         "14053",
  #         "14054",
  #         "14056",
  #         "14057",
  #         "14062",
  #         "14070",
  #         "14071",
  #         "14072",
  #         "14073",
  #         "14074",
  #         "14075",
  #         "14076",
  #         "14077",
  #         "14078",
  #         "14079",
  #         "14080",
  #         "14081",
  #         "14082",
  #         "14196"
  #       ],
  #       "ext" => %{"tag_id" => "206735"},
  #       "id" => "14019",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "VV9 pb BB",
  #       "type" => "show",
  #       "visible" => 1
  #     },
  #     "10000" => %{
  #       "children" => ["10001", "14019", "14063", "14302"],
  #       "ext" => nil,
  #       "id" => "10000",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "RTL24 Application",
  #       "type" => "application",
  #       "visible" => 1
  #     },
  #     "14075" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "191", "parent_id" => "14019"},
  #       "id" => "14075",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Kih_Hunor",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14310" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "219", "parent_id" => "14302"},
  #       "id" => "14310",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "lovasz_laszlo",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "12783" => %{
  #       "children" => [],
  #       "ext" => %{"asset_id" => nil},
  #       "id" => "12783",
  #       "status" => 0,
  #       "sub_type" => "menu_item_vote",
  #       "title" => "Szavazás-2",
  #       "type" => "menu_item",
  #       "visible" => 0
  #     },
  #     "14034" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "162", "parent_id" => "14019"},
  #       "id" => "14034",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Reni",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14030" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "158", "parent_id" => "14019"},
  #       "id" => "14030",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Krisztián",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14063" => %{
  #       "children" => ["10479", "10788", "12783", "13711", "13733", "13758", "14064", "14065", "14083", "14084", "14085", "14086", "14087", "14088", "14089", "14090", "14091", "14092", "14093"],
  #       "ext" => %{"asset_1" => "212", "tag_id" => "175596"},
  #       "id" => "14063",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "X-Faktor 2018",
  #       "type" => "show",
  #       "visible" => 1
  #     },
  #     "10002" => %{
  #       "children" => [],
  #       "ext" => %{"asset_id" => nil},
  #       "id" => "10002",
  #       "status" => 1,
  #       "sub_type" => "menu_item_newsfeed",
  #       "title" => "Top Hírek",
  #       "type" => "menu_item",
  #       "visible" => 1
  #     },
  #     "14042" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "170", "parent_id" => "14019"},
  #       "id" => "14042",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Kiv_Era",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14077" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "193", "parent_id" => "14019"},
  #       "id" => "14077",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Kih_Lacika",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14080" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "196", "parent_id" => "14019"},
  #       "id" => "14080",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Kih_Roli",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14057" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "184", "parent_id" => "14019"},
  #       "id" => "14057",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "dummy2",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14303" => %{
  #       "children" => [],
  #       "ext" => %{"asset_id" => nil},
  #       "id" => "14303",
  #       "status" => 1,
  #       "sub_type" => "menu_item_newsfeed",
  #       "title" => "Pillanatok",
  #       "type" => "menu_item",
  #       "visible" => 1
  #     },
  #     "14037" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "165", "parent_id" => "14019"},
  #       "id" => "14037",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Vivien",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14025" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "153", "parent_id" => "14019"},
  #       "id" => "14025",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Csoki",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14308" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "217", "parent_id" => "14302"},
  #       "id" => "14308",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "korcsolyazok",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14044" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "172", "parent_id" => "14019"},
  #       "id" => "14044",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Kiv_Ginu",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14043" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "171", "parent_id" => "14019"},
  #       "id" => "14043",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Kiv_geri",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14087" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "203", "parent_id" => "14063"},
  #       "id" => "14087",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Ricky and the Drunken Sailors",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14046" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "174", "parent_id" => "14019"},
  #       "id" => "14046",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Kiv_Krisztián",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14084" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "200", "parent_id" => "14063"},
  #       "id" => "14084",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Balog Janó",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "10788" => %{
  #       "children" => [],
  #       "ext" => %{"asset_id" => nil},
  #       "id" => "10788",
  #       "status" => 0,
  #       "sub_type" => "menu_item_vote",
  #       "title" => "Szavazás-3",
  #       "type" => "menu_item",
  #       "visible" => 0
  #     },
  #     "10479" => %{
  #       "children" => [],
  #       "ext" => %{"asset_id" => nil},
  #       "id" => "10479",
  #       "status" => 0,
  #       "sub_type" => "menu_item_vote",
  #       "title" => "Szavazás-4",
  #       "type" => "menu_item",
  #       "visible" => 0
  #     },
  #     "14305" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "214", "parent_id" => "14302"},
  #       "id" => "14305",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "amigos",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14399" => %{
  #       "children" => ["14400"],
  #       "ext" => nil,
  #       "id" => "14399",
  #       "status" => 0,
  #       "sub_type" => "",
  #       "title" => "Finálé 2. - 02.17.",
  #       "type" => "vote_collection",
  #       "visible" => 0
  #     },
  #     "14031" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "159", "parent_id" => "14019"},
  #       "id" => "14031",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Lacika",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14048" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "176", "parent_id" => "14019"},
  #       "id" => "14048",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Kiv_Radics",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14307" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "216", "parent_id" => "14302"},
  #       "id" => "14307",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "kondorosi_eva",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14313" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "222", "parent_id" => "14302"},
  #       "id" => "14313",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "renner",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14090" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "206", "parent_id" => "14063"},
  #       "id" => "14090",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Taka",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14076" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "192", "parent_id" => "14019"},
  #       "id" => "14076",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Kih_Krisztián",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14093" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "209", "parent_id" => "14063"},
  #       "id" => "14093",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "USNK",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14083" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "199", "parent_id" => "14063"},
  #       "id" => "14083",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Arany Tímea",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14047" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "175", "parent_id" => "14019"},
  #       "id" => "14047",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Kiv_Lacika",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14389" => %{
  #       "children" => ["14390"],
  #       "ext" => nil,
  #       "id" => "14389",
  #       "status" => 0,
  #       "sub_type" => "",
  #       "title" => "New Collecton 2019-02-13 21:23:53",
  #       "type" => "vote_collection",
  #       "visible" => 0
  #     },
  #     "14028" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "156", "parent_id" => "14019"},
  #       "id" => "14028",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Ginu",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14022" => %{
  #       "children" => ["14389"],
  #       "ext" => %{"asset_id" => nil},
  #       "id" => "14022",
  #       "status" => 1,
  #       "sub_type" => "menu_item_vote",
  #       "title" => "Kvíz",
  #       "type" => "menu_item",
  #       "visible" => 1
  #     },
  #     "14306" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "215", "parent_id" => "14302"},
  #       "id" => "14306",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "babos_fucsovics",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14029" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "157", "parent_id" => "14019"},
  #       "id" => "14029",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Hunor",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "13711" => %{
  #       "children" => [],
  #       "ext" => %{"asset_id" => nil},
  #       "id" => "13711",
  #       "status" => 0,
  #       "sub_type" => "menu_item_vote",
  #       "title" => "Kvíz",
  #       "type" => "menu_item",
  #       "visible" => 0
  #     },
  #     "14091" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "207", "parent_id" => "14063"},
  #       "id" => "14091",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Tamáska Gabriella",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14391" => %{
  #       "children" => [],
  #       "ext" => %{"asset_1" => "155", "orientation" => "horizontal"},
  #       "id" => "14391",
  #       "status" => 1,
  #       "sub_type" => "vote_option_imgtext",
  #       "title" => "Greg",
  #       "type" => "vote_option",
  #       "visible" => 1
  #     },
  #     "14027" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "155", "parent_id" => "14019"},
  #       "id" => "14027",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Geri",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14089" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "205", "parent_id" => "14063"},
  #       "id" => "14089",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Szekér Gergő",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14049" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "177", "parent_id" => "14019"},
  #       "id" => "14049",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Kiv_Renátó",
  #       "type" => "asset",
  #       "visible" => 1
  #     },
  #     "14071" => %{
  #       "children" => [],
  #       "ext" => %{"url" => "187", "parent_id" => "14019"},
  #       "id" => "14071",
  #       "status" => 1,
  #       "sub_type" => "",
  #       "title" => "Kih_Csoki",
  #       "type" => "asset",
  #       "visible" => 1
  #     }
  #   }
  # end

  # defmodule
end
