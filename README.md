# Adb

Egyenlore semmi.

## Example session

```elixir
send :tdb, ["register", "segg", 0]
send :tdb, ["lock", "segg", 1, [ "14146"]]
 send :tdb, ["data", "segg", 2, %{  "children" => [],  "ext" => %{"url" => "212", "parent_id" => "10002"},  "id" => "14146",  "status" => 1,  "sub_type" => "",  "title" => "XF - Pepsi kampány ",  "type" => "asset",  "visible" => 0}]
```

## Installation

```elixir
def deps do
  [
    {:adb, git: "git@github.com:javobalazs/adb.git", "~> 0.1.0"},
  ]
end
```
