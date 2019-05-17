defmodule Util.Generator do
  @moduledoc """
  A forditashoz mindenfele utility-k.
  """

  @typedoc """
  A purgalas "vegeredmenye".
  """
  @type purgalas :: :generator_soft_purge_ok | :generator_soft_purge_fail | :generator_soft_purge_ok_no_old_code

  @typedoc """
  A forditas "vegeredmenye".
  """
  @type t :: {:ok, purgalas} | {:error, any}

  @doc """
  Lefordit egy modult, es utan purgalja.
  - `mod`: modul neve.
  - `ast`: AST.

  Return: mellekhatas, hibajelzes, a purgalas vegeredmenye.
  """
  @spec compile(Atom.t(), Macro.t()) :: t
  def compile(mod, ast) do
    try do
      Code.compile_quoted(ast)
      {:ok, purge(mod)}
    catch
      x, y -> {:error, {x, y}}
    end

    # def compile
  end

  @doc """
  Old code purge.
  - `mod`: a modul neve.

  Return: mellekhatas, plusz a purgalas vegeredmenye.
  """
  @spec purge(Atom.t()) :: purgalas
  def purge(mod) do
    if :erlang.check_old_code(mod) do
      if :code.soft_purge(mod) do
        :generator_soft_purge_ok
      else
        :generator_soft_purge_fail
      end
    else
      :generator_soft_purge_ok_no_old_code
    end

    # def purge
  end

  # defmodule
end
