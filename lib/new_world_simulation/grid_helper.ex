defmodule NewWorldSimulation.GridHelper do
  alias NewWorldSimulationWeb.SimulationChannel
  alias NewWorldSimulation.Grid

  @move_directions [[1, 0], [-1, 0], [0, -1], [0, 1]]

  def construct_grid(nil) do
    Application.fetch_env!(:new_world_simulation, :grid_dimension)
    |> construct_grid()
  end

  def construct_grid(grid_dimension) do
    for col <- 1..grid_dimension, row <- 1..grid_dimension, into: %{}, do: {{col, row}, []}
  end

  def populate_creatures(grid, nil) do
    Application.fetch_env!(:new_world_simulation, :creature_count)
    |> populate_creatures(grid)
  end

  def populate_creatures({number_of_carrots, number_of_rabbits, number_of_foxes}, grid) do
    fin_state =
      Map.keys(grid)
      |> Enum.take_random(number_of_carrots + number_of_rabbits + number_of_foxes)
      |> Enum.reduce_while(
        %{
          grid: grid,
          creature_counts: {number_of_carrots, number_of_rabbits, number_of_foxes},
          creature_positions: {[], [], []}
        },
        fn random_spawn_site, state ->
          {remaining_carrots, remaining_rabbits, remaining_foxes} = state.creature_counts
          {carrot_positions, rabbit_positions, fox_positions} = state.creature_positions

          cond do
            remaining_carrots > 0 ->
              {:cont,
               %{
                 grid: Map.update!(state.grid, random_spawn_site, &["C" | &1]),
                 creature_counts: {remaining_carrots - 1, remaining_rabbits, remaining_foxes},
                 creature_positions:
                   {[random_spawn_site | carrot_positions], rabbit_positions, fox_positions}
               }}

            remaining_rabbits > 0 ->
              {:cont,
               %{
                 grid: Map.update!(state.grid, random_spawn_site, &["R" | &1]),
                 creature_counts: {remaining_carrots, remaining_rabbits - 1, remaining_foxes},
                 creature_positions:
                   {carrot_positions, [random_spawn_site | rabbit_positions], fox_positions}
               }}

            remaining_foxes > 0 ->
              {:cont,
               %{
                 grid: Map.update!(state.grid, random_spawn_site, &["F" | &1]),
                 creature_counts: {remaining_carrots, remaining_rabbits, remaining_foxes - 1},
                 creature_positions:
                   {carrot_positions, rabbit_positions, [random_spawn_site | fox_positions]}
               }}

            true ->
              {:halt, state}
          end
        end
      )

    {fin_carrot_positions, fin_rabbit_positions, fin_fox_positions} = fin_state.creature_positions

    %{
      grid: fin_state.grid,
      carrot_positions: fin_carrot_positions,
      rabbit_positions: fin_rabbit_positions,
      fox_positions: fin_fox_positions
    }
  end

  def trigger_next_move(nil) do
    Application.fetch_env!(:new_world_simulation, :tickrate)
    |> trigger_next_move()
  end

  def trigger_next_move(tickrate) do
    state = Grid.get_state()

    # Send grid state to frontend
    broadcast_state(state.grid)

    # Sleep according to tickrate
    Process.sleep(tickrate)

    # Next move logic
    apply_next_move(state)
    |> Grid.update_state()

    trigger_next_move(tickrate)
  end

  defp apply_next_move(%{
         grid: grid,
         carrot_positions: carrot_positions,
         rabbit_positions: rabbit_positions,
         fox_positions: fox_positions
       }) do
    # Rabbits move first
    fin_state =
      Enum.reduce(
        rabbit_positions,
        %{grid: grid, rabbit_positions: rabbit_positions},
        fn rabbit_position, state ->
          next_position = next_position(rabbit_position, Map.keys(state.grid))

          updated_grid =
            Map.update!(state.grid, rabbit_position, &List.delete(&1, "R"))
            |> Map.update!(next_position, &["R" | &1])

          updated_rabbit_positions = List.delete(state.rabbit_positions, rabbit_position)

          %{grid: updated_grid, rabbit_positions: [next_position | updated_rabbit_positions]}
        end
      )

    Enum.map(rabbit_positions, fn p_rabbit ->
      Map.update!(grid, p_rabbit, &List.delete(&1, "R"))
    end)

    %{
      grid: fin_state.grid,
      carrot_positions: carrot_positions,
      rabbit_positions: fin_state.rabbit_positions,
      fox_positions: fox_positions
    }
  end

  defp next_position(current_position, grid_keys) do
    Enum.shuffle(@move_directions)
    |> Enum.reduce_while(current_position, fn [move_x, move_y], {pos_x, pos_y} ->
      updated_position = {pos_x + move_x, pos_y + move_y}

      if position_valid?(grid_keys, updated_position) do
        {:halt, updated_position}
      else
        {:cont, {pos_x, pos_y}}
      end
    end)
  end

  defp position_valid?(keys, position), do: Enum.member?(keys, position)

  def get_creature_positions(grid) do
    Enum.reduce(grid, {[], [], []}, fn {grid_point, creatures_present},
                                       {carrot_positions, rabbit_positions, fox_positions} ->
      Enum.each(creatures_present, fn creature ->
        case creature do
          "C" -> {carrot_positions ++ grid_point, rabbit_positions, fox_positions}
          "R" -> {carrot_positions, rabbit_positions ++ grid_point, fox_positions}
          "F" -> {carrot_positions, rabbit_positions, fox_positions ++ grid_point}
        end
      end)
    end)
  end

  def broadcast_state(grid) do
    SimulationChannel.send_to_channel(grid)
  end
end
