defmodule Util.GlobalGenerator do
  @vsn "1.0.2"
  @moduledoc """
  Globalisokat lehet benne elhelyezni.

  @vsn "#{@vsn}"
  """

  @typedoc """
  A forditas "vegeredmenye".

  - A `Generator.t` akkor jon, ha tenylegesen generalni probal.
  - Az `{:ok, :no_change_in_map}` akkor jon, ha a generalasi map megegyezik a regivel.
    - Mivel a generalas "draga", a map-osszehasonlitas "olcso", erdemes megcsinalni.
  """
  @type t :: Generator.t() | {:ok, :no_change_in_map}

  # @doc """
  # Legeneralja a modul belsejet alkoto fuggvenyeket.
  #
  # - `lista`: egy proplist, ahol az elso elem egy atom,
  #   az lesz majd a fuggveny neve, a masodik elem pedig a tartalom,
  #   amit vissza kell adnia, mar `Macro.escape` utan.
  # - `akk`: akkumulator.
  #
  # Return: a modul belsejenek ast-je.
  # """
  @spec general_fuggvenyek([{atom, any}], any) :: Macro.t()
  defp general_fuggvenyek(lista, akk \\ []) do
    case lista do
      [] ->
        akk

      [{x, y} | b] ->
        res =
          quote do
            def unquote(x)() do
              unquote(y)
            end
          end

        general_fuggvenyek(b, [res | akk])
    end
  end

  @sajat [:x_generalasi_map, :x_fordit, :x_parancs, :x_string_parancs, :x_kiir, :x_iora]

  @doc """
  General egy uj modult, ugy, hogy annak tartalmat felulirja.

  - `mod`: a modul neve.
  - `map`: a tartalma, feltetelezes, hogy a kulcsok atomok.

  Return: a generalt modul ast-je.
  """
  @spec generate_overwrite(atom, Map.t(atom, any)) :: Macro.t()
  def generate_overwrite(mod, map) do
    map = Map.drop(map, @sajat)
    cuccok = Map.to_list(map) |> Enum.map(fn {x, y} -> {x, Macro.escape(y)} end)
    map_q = Macro.escape(map)

    gen_par =
      quote do
        GlobalGenerator.generate_overwrite(unquote(mod), unquote(map_q))
      end

    kiir =
      quote do
        Macro.to_string(unquote(mod).x_parancs)
      end

    ford_kiir =
      Macro.to_string(
        quote do
          GlobalGenerator.fordit_overwrite(unquote(mod), unquote(map_q))
        end
      )

    iora =
      quote do
        IO.puts(unquote(mod).x_kiir)
      end

    cuccok = [{:x_fordit, ford_kiir}, {:x_parancs, gen_par}, {:x_string_parancs, Macro.to_string(gen_par)}, {:x_kiir, kiir}, {:x_iora, iora}, {:x_generalasi_map, map_q} | cuccok]

    quote do
      defmodule unquote(mod) do
        unquote({:__block__, [], general_fuggvenyek(cuccok)})
      end
    end

    # def generate_oveerwrite
  end

  @doc """
  A modulbol biztonsagosan kiszedi a regi map-ot.

  - `mod`: a modul neve.

  Return: a regi map, vagy ures, ha nem volt.
  """
  @spec get_old_map(Atom.t()) :: Map.t()
  def get_old_map(mod) do
    try do
      fun = &mod.x_generalasi_map/0
      fun.()
    catch
      _, _ -> %{}
    end
  end

  @doc """
  General egy uj modult, ugy, hogy annak tartalmat beolvasztja.
  - Kulcsutkozes eseten az uj map az iranyado.

  Parameterek:
  - `mod`: a modul neve.
  - `map`: a tartalma, feltetelezes, hogy a kulcsok atomok.

  Return: a generalt modul ast-je.
  """
  @spec generate_merge(atom, Map.t(atom, any)) :: Macro.t()
  def generate_merge(mod, map) do
    regi_map = get_old_map(mod)
    generate_overwrite(mod, Map.merge(regi_map, map))
  end

  @doc """
  Fordit egy uj modult, ugy, hogy annak tartalmat felulirja.

  - `mod`: a modul neve.
  - `map`: a tartalma, feltetelezes, hogy a kulcsok atomok.

  Return: a forditasi vegeredmeny (plusz mellekhatas)
  """
  @spec fordit_overwrite(atom, Map.t(atom, any)) :: t
  def fordit_overwrite(mod, map), do: fordit_overwrite_aux(mod, map, get_old_map(mod))

  @doc """
  Fordit egy uj modult, ugy, hogy annak tartalmat felulirja.
  - Osszeveti a regit az ujjal, ha az nem `nil`.

  Parameterek:
  - `mod`: a modul neve.
  - `map`: a tartalma, feltetelezes, hogy a kulcsok atomok.
  - `oldmap`: a regi tartalom.

  Return: a forditasi vegeredmeny (plusz mellekhatas)
  """
  @spec fordit_overwrite_aux(atom, Map.t(atom, any), Map.t(atom, any)) :: t
  def fordit_overwrite_aux(mod, map, oldmap) do
    if map != oldmap do
      ast = generate_overwrite(mod, map)
      Util.Generator.compile(mod, ast)
    else
      {:ok, :no_change_in_map}
    end
  end

  @doc """
  Fordit egy uj modult, ugy, beolvasztja a regi tartalmat.
  - Osszeveti a regit az ujjal, ha az nem `nil`.

  Parameterek:
  - `mod`: a modul neve.
  - `map`: a tartalma, feltetelezes, hogy a kulcsok atomok.
  - `oldmap`: a regi tartalom.

  Return: a forditasi vegeredmeny (plusz mellekhatas)
  """
  @spec fordit_merge(atom, Map.t(atom, any)) :: t
  def fordit_merge(mod, map) do
    old = get_old_map(mod)
    fordit_overwrite_aux(mod, Map.merge(old, map), old)
  end

  # defmodule
end
