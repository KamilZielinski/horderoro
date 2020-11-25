defmodule Conv.ConversationSupervisor do
  use Horde.DynamicSupervisor

  alias Conv.ConversationWorker

  def start_link(init_arg) do
    Horde.DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    Horde.DynamicSupervisor.init(strategy: :one_for_one, members: :auto)
  end

  def start_work() do
    spec = %{
      id: ConversationWorker,
      start: {ConversationWorker, :start_link, []},
      restart: :transient
    }

    Horde.DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def count_children do
    Horde.DynamicSupervisor.count_children(__MODULE__)
  end
end
