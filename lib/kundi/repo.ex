defmodule Kundi.Repo do
  use Ecto.Repo,
    otp_app: :kundi,
    adapter: Ecto.Adapters.Postgres
end
