alias ADB.Stage
alias ADB.Rule
alias ADB.Mulmap

defmodule Rule do
  defstruct name: "",
            binding: %{},
            binding_eff: [],
            observe1: [],
            observe2: [],
            observe12: [],
            observe1_eff: [],
            observe2_eff: [],
            observe12_eff: [],
            kernel: false,
            burst: :cpu,
            function: nil,
            constructor: nil,
            destructor: nil

  @type t :: %__MODULE__{
          name: Mulmap.iden(),
          binding: binding,
          binding_eff: [Mulmap.iden()],
          observe1: [Mulmap.iden()],
          observe2: [Mulmap.iden()],
          observe12: [{Mulmap.iden(), Mulmap.iden()}],
          observe1_eff: [Mulmap.iden()],
          observe2_eff: [Mulmap.iden()],
          observe12_eff: [{Mulmap.iden(), Mulmap.iden()}],
          kernel: Boolean.t(),
          burst: burst,
          function: functionx,
          constructor: functionx | nil,
          destructor: functionx | nil
        }

  # Nincs checkin, eleve olyan formaban varjuk el az inputot, hogy insert lehessen, es onnan cpu-szabalyokkal mar meg lehet csinalni a checkin-t.
  @type burst :: :cpu | :checkout
  @type binding :: %{String.t() => String.t()}
  @type binding_list :: [{String.t(), String.t()}]
  @type functionx :: (Stage.t() -> Stage.t())

  @spec constructor(
          name :: Mulmap.iden(),
          binding :: binding_list,
          observe1 :: [Mulmap.iden()],
          observe2 :: [Mulmap.iden()],
          observe12 :: [{Mulmap.iden(), Mulmap.iden()}],
          kernel :: Boolean.t(),
          burst :: burst,
          function :: functionx,
          constructor :: functionx | nil,
          destructor :: functionx | nil
        ) :: t
  def constructor(name, binding, observe1, observe2, observe12, kernel, burst, function, constructor \\ nil, destructor \\ nil) do
    # Effektiv ertekek szamitasa
    binding = Map.new(binding)
    binding_eff = Map.values(binding)

    # Visszakodolas
    observe1_eff = Map.take(binding, observe1) |> Map.keys()
    observe2_eff = Map.take(binding, observe2) |> Map.keys()
    observe12_eff = observe12 |> Enum.map(fn {map, key} -> {Map.get(binding, map), Map.get(binding, key)} end)

    %__MODULE__{
      name: name,
      binding: binding,
      binding_eff: binding_eff,
      observe1: observe1,
      observe2: observe2,
      observe12: observe12,
      observe1_eff: observe1_eff,
      observe2_eff: observe2_eff,
      observe12_eff: observe12_eff,
      kernel: kernel,
      burst: burst,
      function: function,
      constructor: constructor,
      destructor: destructor
    }
  end
end
