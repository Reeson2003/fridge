defmodule Fridge.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Fridge, name: Fridge},
      {NoHumanFridge, name: NoHumanFridge},
      {VeganFridge, name: VeganFridge}
    ]

    opts = [
      strategy: :one_for_one,
      name: Fridge.Supervisor,
      strategy: :one_for_one,
      name: NoHumanFridge.Supervisor,
      strategy: :one_for_one,
      name: VeganFridge.Supervisor,
    ]
    Supervisor.start_link(children, opts)
  end
end
