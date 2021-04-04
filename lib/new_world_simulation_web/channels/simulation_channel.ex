defmodule NewWorldSimulationWeb.SimulationChannel do
  use Phoenix.Channel

  def send_to_channel(data) do
    Phoenix.PubSub.broadcast(
      NewWorldSimulation.PubSub,
      "simulation:predator_pray",
      %{type: "simulation_tick_update", payload: data}
    )
  end

  def join("simulation:predator_pray", _payload, socket) do
    {:ok, socket}
  end

  def handle_info(%{type: "simulation_tick_update"} = info, socket) do
    info =
      Map.update!(info, :payload, fn grid_data ->
        for {k, v} <- grid_data, into: %{}, do: {Kernel.inspect(k), v}
      end)
      |> IO.inspect()

    push(socket, "simulation_tick_update", info)

    {:noreply, socket}
  end
end
