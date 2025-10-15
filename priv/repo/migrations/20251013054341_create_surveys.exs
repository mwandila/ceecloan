defmodule Ceec.Repo.Migrations.CreateSurveys do
  use Ecto.Migration

  def change do
    create table(:surveys) do
      add :title, :string, null: false
      add :description, :string, null: false
      add :status, :string, default: "draft", null: false
      add :created_by, :string, null: false
      add :start_date, :date
      add :end_date, :date

      timestamps()
    end

    create index(:surveys, [:status])
    create index(:surveys, [:created_by])
  end
end
