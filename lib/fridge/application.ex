defmodule Fridge.Application do
  use Application

  def start(_type, _args) do
    children = [
      {NoHumanFridge, name: NoHumanFridge}
    ]

    opts = [strategy: :one_for_one, name: NoHumanFridge.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
