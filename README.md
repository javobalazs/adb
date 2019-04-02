# Adb

Egyenlore semmi.

## Example session

```elixir
R24Core.start_link :tdb
send :tdb, ["register", "segg", 0, 0]
send :tdb, ["lock", "segg", 1, 0, "u0", ["14146"]]
send :tdb, ["data", "segg", 2, 1, "u1", %{  "children" => [],  "ext" => %{"parent_id" => "10006"},  "id" => "14146",    "visible" => 0}]
send :tdb, ["unlock", "segg", 3, 2, "u2", [ "14146"]]
send :tdb, ["register", "segg", 4, 3]
send :tdb, ["register", "segg", 4, 4]
```

## Installation

```elixir
def deps do
  [
    {:adb, git: "git@github.com:javobalazs/adb.git", tag: "0.1.4"},
  ]
end
```
