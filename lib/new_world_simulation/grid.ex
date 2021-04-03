defmodule NewWorldSimulation.Grid do
  use GenServer
  alias NewWorldSimulation.GridHelper

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: Grid)
  end

  @impl true
  def init(state), do: {:ok, state}

  # Client API
  def start(args) do
    # Grid setup
    init_state =
      GridHelper.construct_grid(args[:grid_dimension])
      |> GridHelper.populate_creatures(args[:creatures])

    # Store grid state
    update_state(init_state)

    # Kickoff simulation loop
    GridHelper.trigger_next_move(args[:tickrate])
  end

  def update_state(state) do
    GenServer.cast(
      Grid,
      {:update_state,
       %{
         grid: state.grid,
         carrot_positions: state.carrot_positions,
         rabbit_positions: state.rabbit_positions,
         fox_positions: state.fox_positions
       }}
    )
  end

  def get_state() do
    GenServer.call(Grid, :get_state)
  end

  @impl true
  def handle_cast({:update_state, new_state}, _state) do
    {:noreply, new_state}
  end

  @impl true
  def handle_call(:get_state, _from, state), do: {:reply, state, state}
end
