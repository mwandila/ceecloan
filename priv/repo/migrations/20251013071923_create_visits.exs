defmodule Ceec.Repo.Migrations.CreateVisits do
  use Ecto.Migration

  def change do
    create table(:visits) do
      add :visit_date, :date
      add :visit_type, :string
      add :purpose, :string
      add :findings, :text
      add :recommendations, :text
      add :visited_by, :string
      add :gps_latitude, :float
      add :gps_longitude, :float
      add :status, :string
      add :notes, :text
      add :project_id, references(:projects, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:visits, [:project_id])
  end
end
