defmodule NoHumanFridge do
  use Fridge.Fridge

  def check_type(type) do
    type != "human"
  end

end
