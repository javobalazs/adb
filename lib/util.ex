defmodule Util do
  @moduledoc """
  A `@docp` bevezetese es error-monad, illetve mindenfele szir-szar. A tobbfele hasznalat kompatibilis!

  Egyreszt arra valo, hogy tudjak privat fuggvenyeknek `@docp` attributumot adni.
  Ekkor hasznalata:

  ```elixir
  defmodule Valamilyen.Modul do
    # Mindenfele kod.
    # Mindenfele kod.
    # Mindenfele kod.

    # Es a legvegen:
    use Util
    # defmodule
  end
  ```

  Plusz: error-monad(-szeruseg). A `with` utasitas helyett, ami szerintem szar.
  Hasznalata:
  ```elixir
  defmodule Valamilyen.Modul do
    import Util

    def xxx do
      # ...
      wmonad do
        wo(:ok) = if feltetel, do: wo(:ok), else: wf("elbasztad_valamiert")
      end
      # ...
    end

  Szir-szar:
  - `wfix(x, default)`: `x` erteke marad, ha nem `nil`, kulonben `default`.
  - `wife(x, default)`: `x`, ha nem `nil`, kulonben `default`.
    if condi, do: clause, else: var

    # defmodule
  end
  ```

  """

  defmacro __using__([]) do
    quote do
      @docp "placeholder"
      @doc "A kurva docp-warning miatt kell ez."
      @spec docp() :: String.t()
      def docp, do: @docp
    end
  end

  @typedoc "Error-monad. Az `:error`-hoz tartozo barmi lehet."
  @type w(a) :: {:ok, a} | {:error, any}

  @doc """
  Hiba eseten "hozzarak" egy potlolagos hibauzenetet-darabot egy space-szel.

  Parameterek:
  - `x`: a monad.
  - `y`: ha `x == {:error, hiba}`, akkor `y`-t hozza kell fuzni `hiba`-hoz.

  Return: `x`, esetleg modositva, ha hiba volt.
  """
  def wext(x, y) do
    case x do
      {:ok, _} -> x
      {:error, hiba} -> {:error, "#{hiba}_#{y}"}
    end
  end

  @doc """
  Megfelel a Haskell `return(x)` muveletnek.
  """
  defmacro wo(x) do
    {:ok, x}
  end

  @doc """
  Megfelel a `fail(x)` muveletnek.

  Parameterek:
  - `x`: ami a fail-ben visszamegy.

  Return: makrokent `{:error, x}`.
  """
  @spec wf(String.t()) :: Macro.t()
  defmacro wf(x) do
    quote do
      {:error, unquote(x)}
    end
  end

  @doc """
  Egyszeru szintaktikai elem a Haskell `do`-jelolesere.

  Hasznalata:
  ```
  wmonad do
    utasitasok
    pl. wo(z) = kif
  end
  ```

  Megjegyzesek:
  - Ha match-hiba van, visszaadja a hibazo cuccot.
  """
  defmacro wmonad(do: clause) do
    quote do
      try do
        unquote(clause)
      rescue
        err in [MatchError] ->
          %MatchError{term: t} = err
          t
      catch
        :badmatch, x -> x
      end
    end

    # defmacro wmonad
  end

  @doc """
  `wfix(x, default)`: `x` erteke marad, ha nem `nil`, kulonben `default`.
  """
  @spec wfix(any, any) :: Macro.t()
  defmacro wfix(x, default) do
    quote do
      unquote(x) = if unquote(x) == nil, do: unquote(default), else: unquote(x)
    end
  end

  @doc """
  Ekvivalens:
  ```elixir
  var = if condi, do: clause, else: var
  ```
  """
  defmacro wif(var, condi, do: clause) do
    quote do
      unquote(var) =
        if unquote(condi) do
          unquote(clause)
        else
          unquote(var)
        end
    end
  end

  @doc """
  Kifejezes, ekvivalens:
  ```elixir
  if condi, do: clause, else: var
  ```
  """
  defmacro wife(var, condi, do: clause) do
    quote do
      if unquote(condi) do
        unquote(clause)
      else
        unquote(var)
      end
    end
  end

  # defmodule
end
