defmodule Conv.Repo do
  use Ecto.Repo,
    otp_app: :conv,
    adapter: Ecto.Adapters.Postgres
end
