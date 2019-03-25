defmodule AdbTest do
  use ExUnit.Case
  doctest Adb

  test "greets the world" do
    assert Adb.hello() == :world
  end
end
