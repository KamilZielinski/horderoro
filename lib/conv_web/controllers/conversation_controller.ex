defmodule ConvWeb.ConversationController do
  use ConvWeb, :controller

  alias Conv.ConversationSupervisor

  @spec index(Plug.Conn.t(), any) :: Plug.Conn.t()
  def index(conn, _params) do
    # Enum.each(1..20, fn _ -> ConversationSupervisor.start_work() end)
    ConversationSupervisor.start_work()
    users = []
    json(conn, users)
  end

  def create(conn, _params) do
    conv_id = conn.query_params["conv_id"]
    [{pid, _}] = Horde.Registry.lookup(ConversationRegistry, "conversation_#{conv_id}")
    GenServer.cast(pid, {:add, "message_#{Ecto.UUID.generate()}"})
    users = []
    json(conn, users)
  end
end
