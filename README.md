# Adb

Egyenlore semmi.

## Example session

```elixir
send :tdb, ["register", "segg", 0]
send :tdb, ["lock", "segg", 1, ["14146"]]
send :tdb, ["data_update", "segg", 2, %{"id" => "14146", "visible" => 0, "ext" => %{"parent_id" => "10001"}}]
```

## Installation

```elixir
def deps do
  [
    {:adb, git: "git@github.com:javobalazs/adb.git", tag: "0.1.2"},
  ]
end
```
