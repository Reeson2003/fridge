defmodule VeganFridge do
  use Fridge.Fridge

  def check_type(type) do
    type != "seafood" && type != "meat"
  end

end
