defmodule Conv.ConversationWorker do
  use GenServer

  @conversation_window_ms 60_000

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_state \\ []) do
    registered_name = process_name()
    {_, _, {_, conv_id}} = registered_name
    :logger.info("#{node()}:Created conversation with id: #{conv_id}")
    GenServer.start_link(__MODULE__, [], name: registered_name)
  end

  @spec init(any) :: {:ok, %{messages: [], status: :inactive, timer_ref: reference}}
  def init(_state) do
    timer_ref = Process.send_after(self(), :close_conversation, @conversation_window_ms)
    {:ok, %{status: :inactive, messages: [], timer_ref: timer_ref}}
  end

  def handle_cast({:add, item}, state) do
    new_timer_ref = reschedule_kill(state.timer_ref)
    new_array = state.messages ++ [item]

    :logger.debug(new_array)
    schedule_send()
    {:noreply, %{status: :active, messages: new_array, timer_ref: new_timer_ref}}
  end

  def handle_info(:send, state) do
    Enum.each(state.messages, fn mess -> :logger.info("#{node()}:Sending message: #{mess}") end)

    new_state =
      state
      |> Map.replace!(:status, :inactive)
      |> Map.replace!(:messages, [])

    {:noreply, new_state}
  end

  def handle_info(:close_conversation, state) do
    :logger.info(
      "#{node()}: Closing the conversation. No more messages being processed but new messages may land in the mailbox!"
    )

    {:stop, :normal, state}
  end

  def terminate(reason, state) do
    :logger.info("#{node()}:Storing state in the database")
    :timer.sleep(10_000)
    :logger.info("#{node()}:Saving logs")
    :timer.sleep(10_000)

    :logger.debug("#{node()}:Terminating with state: #{inspect(state)}")
    :logger.debug("#{node()}:The reason was: #{inspect(reason)}")
    reason
  end

  defp reschedule_kill(timer_ref) do
    :logger.info("#{node()}:Extending conversation by #{@conversation_window_ms}ms")
    Process.cancel_timer(timer_ref)
    Process.send_after(self(), :close_conversation, @conversation_window_ms)
  end

  defp schedule_send do
    Process.send_after(self(), :send, 1_000)
  end

  # In case of failure process will be restarted and created with a new name.
  # It should get its name from outside
  defp process_name() do
    {:via, Horde.Registry, {ConversationRegistry, "conversation_#{Ecto.UUID.generate()}"}}
  end
end
