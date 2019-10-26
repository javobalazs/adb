alias ADB.Stage
alias ADB.Rule
alias ADB.Mulmap

defmodule Rule do
  defstruct name: "",
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
          observe1_eff: [Mulmap.iden()],
          observe2_eff: [Mulmap.iden()],
          observe12_eff: [{Mulmap.iden(), Mulmap.iden()}],
          kernel: Boolean.t(),
          burst: burst,
          function: functionx,
          constructor: functionx | nil,
          destructor: functionx | nil
        }

  @typedoc """
  Nincs checkin, eleve olyan formaban varjuk el az inputot, hogy insert lehessen, es onnan cpu-szabalyokkal mar meg lehet csinalni a checkin-t.

  - ':checkin': az input elokeszitese ugy, hogy mar hasznalhat belso tablakat, de hivhat imperativ muveleteket is.
  - `:cpu`: az igazi uzleti logika.
  - `:checkout`: az output elkeszitese, illetve cleanup.
  """
  @type burst :: :cpu | :checkout | :checkin
  @type functionx :: (Stage.t() -> Stage.t())

  @spec constructor(
          name :: Mulmap.iden(),
          observe1 :: [Mulmap.iden()],
          observe2 :: [Mulmap.iden()],
          observe12 :: [{Mulmap.iden(), Mulmap.iden()}],
          kernel :: Boolean.t(),
          burst :: burst,
          function :: functionx,
          constructor :: functionx | nil,
          destructor :: functionx | nil
        ) :: t
  def constructor(name, observe1, observe2, observe12, kernel, burst, function, constructor \\ nil, destructor \\ nil) do
    %__MODULE__{
      name: name,
      observe1_eff: observe1,
      observe2_eff: observe2,
      observe12_eff: observe12,
      kernel: kernel,
      burst: burst,
      function: function,
      constructor: constructor,
      destructor: destructor
    }
  end
end
