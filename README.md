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
## With

Egyszeru error monad, az elixir `with` utasitasa helyett, ami szar.

```elixir
import Util
```
A helyi "`do`-notation":
```elixir
wmonad do
  wo(x) = monadikus muvelet x-szel
  wo(x) = monadikus muvelet x-szel
  wo(x) = monadikus muvelet x-szel
  monadikus muvelet x-szel
end
```

Ha valami hiba van:
```elixir
wmonad do
  wo(x) = if x.ertek == joertek, do: wo(x transzformalva), else: we "elbaszott_attributum: #{inspect x.ertek}, elvart: #{inspect joertek}"
end
```

Ritkabban:
```elixir
wmonad do
  wo(x) = if x.ertek == joertek, do: wo(x transzformalva), else: wf {:elbaszott_attributum, x.ertek}
end
```

Ha a hibauzenet szoveges, eggyel magasabb szinten ki lehet egesziteni:
```elixir
wo(valami) = wext monadikus_fuggveny(valami), " izemize"
```
Ilyenkor, ha hiba van, a hibauzenethez hozzacsapodik az `"izemize"`.

## Pdecoder

Struktura-ellenorzo parsolt dolgokhoz.

- Lehetove teszi, hogy megnezzuk, egy (opcionalisan mar parsolt) JSON-nak
  a megfelelo mezoi vannak-e. Ha igen, ezeket atomma alakitja.
- Infrastrukturat ad arra, hogy a szemantikai ellenorzest elvegezhessuk.

```elixir
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

### `check_callback`
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

## Comment

Blokk-kommentek, mivel megszuntettek a `@docp` lehetoseget.

```elixir
import Util

comment "Ez egy komment."

comment """
Ez egy tobbsoros
k-nagy komment.
"""
```

## `LogRotator`

A napi logokat intezi a `:loggger_file_backend`-hez.

`app.ex`:
```elixir
defmodule App do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      Util.LogRotator.child_spec(:error_log)
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: :supervisor)
  end
end

```

`config.exs`:
```elixir
use Mix.Config

config :logger,
  backends: [{LoggerFileBackend, :error_log}, :console]

# configuration for the {LoggerFileBackend, :error_log} backend
config :logger, :error_log,
  path: "log/inst.log",
  format: "$date $time $metadata[$level] $levelpad$message\n",
  metadata: [:line],
  level: :info

# level: :error

config :logger, :console,
  format: "$date $time $metadata[$level] $levelpad$message\n",
  metadata: [:line]
```

## Installation

```elixir
def deps do
  [
    {:adb, git: "git@github.com:javobalazs/adb.git", tag: "0.2.4"},
  ]
end
```
