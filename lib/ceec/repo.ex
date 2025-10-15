defmodule Ceec.Repo do
  use Ecto.Repo,
    otp_app: :ceec,
    adapter: Ecto.Adapters.Postgres
end
