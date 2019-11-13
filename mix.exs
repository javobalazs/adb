defmodule Adb.MixProject do
  use Mix.Project
  @vsn "0.3.2"

  def project do
    [
      app: :adb,
      version: @vsn,
      elixir: "~> 1.8",
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp package do
    [
      licenses: ["BEER-WARE"]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      # {:cbt, git: "git@github.com:javobalazs/cbt.git", tag: "1.2.3"},
      {:timex, "~> 3.6"},
      # {:tzdata, "~> 0.5"},
      {:logger_file_backend, "~> 0.0.10"}
    ]
  end
end
