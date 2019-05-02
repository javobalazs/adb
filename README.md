# Adb

Egyenlore semmi.

## Example session

Az `R24Core` modulban.

Szinkronos hivasnal:

```elixir
task = Task.async(fn -> send :tdb, ["sync", self(), uuid, "new_id"]; receive do msg -> msg end end)
res = Task.await(task)
# ...
res = Task.async(fn -> send :tdb, ["sync", self(), uuid, "new_id"]; receive do msg -> msg end end) |> Task.await()
# ...
res = Task.async(fn -> sl = self(); send :tdb, ["sync", sl, inspect(sl), {"counters", counters}]; receive do msg -> msg end end) |> Task.await()
```

## Installation

```elixir
def deps do
  [
    {:adb, git: "git@github.com:javobalazs/adb.git", tag: "0.2.3"},
  ]
end
```
