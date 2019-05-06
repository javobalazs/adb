# FONTOS! Ha a `moduledoc` vagy a `check_callback` dokumentacioja valtozik,
#   be kell masolni a `README.md`-be!

defmodule Util.Pdecoder do
  @moduledoc """
  Struktura-ellenorzo parsolt dolgokhoz.
  - Lehetove teszi, hogy megnezzuk, egy (opcionalisan mar parsolt) JSON-nak
    a megfelelo mezoi vannak-e. Ha igen, ezeket atomma alakitja.
  - Infrastrukturat ad arra, hogy a szemantikai ellenorzest elvegezhessuk.

  Hasznalat:
  ```
  use Pdecoder, fields: fl, type: tp, only_fields: only_f
  ```

  Ha a defaultot akarjuk hasznalni csak, akkor:
  ```elixir
  def check_callback(x,not_found,surplus), do: check_callback_default(x,not_found,surplus)
  ```

  Parameterek:
  - `fields`: a tipus mezoinek listaja.
    - Lehetnek csak atomok,
    - vagy kulcslista.
  - `type`: a tipus specifikacioja.
  - `only_fields`: csak a megadott mezok lehetnek benne.

  Feltetelezes:
  - `%__MODULE__{}` a struktura, amire ez vonatkozik!

  Egyeb:
  - A `check_callback` lehetoseget ad szemantikai ellenorzesre.
  """

  @check_callback_doc """
  Szemantikai es egyeb ellenorzesi es konvertalasi lehetoseg
  a felhasznalonak, ha mar a struktura alapvetoen jonak bizonyul,
  ti. a kulcsok valoban megfeleloek.

  - Van egy default-implementacio, `check_callback_default`, ami "helybenhagyja" a strukturat.

  Parameterek:
  - `str`: az eddig elkeszult resze a strukturanak.
  - `not_found`: az eredeti strukturanak az a resze (azok a kulcsok),
    melyekhez nem volt a parsolt strukturaban megfelelo string-kulcs.
  - `surplus`: azon resze az eredeti map-nek,
    melynek nincs megfeleloje a specifikacioban, azaz plusz-mezok.

  Return:
  - A feljavitott `str`.
  - `With`-monadban, ha hiba van.
  """
  @doc @check_callback_doc
  @callback check_callback(Map.t(atom, any), Map.t(atom, any), Map.t(String.t(), any)) :: With.t(Map.t(atom, any))

  @typedoc """
  Az altalanos, parsolas utani JSON-tipus, csak hogy jobban latszodjek.

  - String-kulcsos map.
  """
  @type json :: Map.t(String.t(), any)

  @doc "A `__using__` macro, dokumentacioja a modul dokujaban."
  @spec __using__(fields: [atom] | Keyword.t(), type: any, only_fields: Boolean.t()) :: Macro.t()
  defmacro __using__(fields: mz, type: tp, only_fields: only_f) do
    quote location: :keep do
      @behaviour Util.Pdecoder
      require Util

      # Leszurjuk a mezoket es elokeszitunk meg forditasi idoben par valtozot.
      @mezok unquote(mz)
             |> Enum.map(fn x ->
               case x do
                 {k, _v} -> k
                 _ -> x
               end
             end)

      # IO.puts("itt #{inspect(@mezok)}")

      @mezok_s_a Enum.map(@mezok, fn m -> {Atom.to_string(m), m} end)
      # IO.puts("itt #{inspect(@mezok_s_a)}")
      @mezok_s_a_m Map.new(@mezok_s_a)
      @struct_nil Enum.map(@mezok, fn m -> {m, nil} end) |> Map.new()
      # IO.puts("itt #{inspect(@struct_nil)}")

      @doc """
      Ellenoriz egy (JSON-bol jott, frissen parsolt) strukturat,
      hogy a megadott specifikaciok megfelelnek-e a mezonevek,
      illetve a mezoertekek.

      - Eloallitja a vegso struktura egy kozeliteset ugy,
        hogy az eddigi `String.t` kulcsokat atomra valtja,
        es berakja egy strukturaba.
      - A vegen meghivja a `check_callback`-et, melyet
        ujra lehet definialni, es ahol a felhasznalo
        egyeb ellenorzeseket vegez. A callback egy parametere
        azoknak mezoknek a `map`-je, melyek hianyoztak
        parsolt strukturabol.

      Parameterek:
      - `mp`: az eredeti parsolt JSON, string-tipusu kulcsokkal.

      Return:
      - A megfeleloen beparsolt, atom-kulcsos eredmenyt.
      - `With`-monadban.
      """
      @spec check(Pdecoder.json()) :: With.t(unquote(tp))
      def check(mp) do
        if is_map(mp) do
          mpl = Map.to_list(mp)
          {x, surplus} = check_aux(mpl)
          # IO.puts("kaptam x: #{inspect x}, surplus: #{inspect surplus} " )
          kulcsok = Enum.map(x, fn {k, _v} -> k end)
          # IO.puts("kaptam kulcsok: #{inspect kulcsok}")
          not_found = :maps.without(kulcsok, @struct_nil)
          # IO.puts("kaptam not_found: #{inspect not_found}")
          surplus = Map.new(surplus)

          unquote(
            if only_f do
              quote do
                if surplus != %{} do
                  Util.wf(SURPLUS_FIELDS)
                else
                  check_callback(Map.merge(%__MODULE__{}, Map.new(x)), not_found, surplus)
                end
              end
            else
              quote do
                check_callback(Map.merge(%__MODULE__{}, Map.new(x)), not_found, surplus)
              end
            end
          )
        else
          Util.wf(GOT_NOT_MAP)
        end
      end

      # @doc """
      # Atvaltja a parsolt struktura string-kulcsait atomra, ha lehet.
      #
      # - `mpl`: kulcs-ertek-lista, ahol a kulcs `String.t`.
      # - `akk`: akkumulator, az eddig ellenorzott es elfogadott
      #   atom-forditasai a kulcsoknak.
      # - `akk2`: akkumulator azokkal az eredeti kulcsokkal es ertekekkel,
      #   melyekhez nem talalt atomot.
      #
      # Return: `{akk, akk2}`.
      # """
      @spec check_aux([{String.t(), any}], Keyword.t()) :: {Keyword.t(), Map.t(atom, any)}
      defp check_aux(mpl, akk \\ [], akk2 \\ []) do
        case mpl do
          [{ks, v} | tail] ->
            k_atom = Map.get(@mezok_s_a_m, ks)

            if k_atom == nil do
              check_aux(tail, akk, [{ks, v} | akk2])
            else
              check_aux(tail, [{k_atom, v} | akk], akk2)
            end

          [] ->
            {akk, akk2}
        end
      end

      @doc unquote(@check_callback_doc)
      @spec check_callback_default(unquote(tp), Map.t(atom, any), Map.t(String.t(), any)) :: With.t(unquote(tp))
      def check_callback_default(str, _not_found, _surplus), do: Util.wo(str)

      @spec check_callback(unquote(tp), Map.t(atom, any), Map.t(String.t(), any)) :: With.t(unquote(tp))

      # quote
    end

    # defmacro __using__
  end

  # defmodule
end
