defmodule Ceec.MeData.Visit do
  use Ecto.Schema
  import Ecto.Changeset

  schema "visits" do
    field :findings, :string
    field :gps_latitude, :float
    field :gps_longitude, :float
    field :notes, :string
    field :purpose, :string
    field :recommendations, :string
    field :status, :string
    field :visit_date, :date
    field :visit_type, :string
    field :visited_by, :string
    field :project_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(visit, attrs) do
    visit
    |> cast(attrs, [:visit_date, :visit_type, :purpose, :findings, :recommendations, :visited_by, :gps_latitude, :gps_longitude, :status, :notes])
    |> validate_required([:visit_date, :visit_type, :purpose, :findings, :recommendations, :visited_by, :gps_latitude, :gps_longitude, :status, :notes])
  end
end
