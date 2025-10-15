defmodule Ceec.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :name, :string, null: false
      add :description, :text
      add :project_code, :string, null: false
      add :status, :string, null: false, default: "active"
      add :start_date, :date, null: false
      add :end_date, :date
      add :budget, :decimal, precision: 15, scale: 2
      add :currency, :string, default: "USD"
      
      # Geographic and administrative info
      add :country, :string, null: false
      add :region, :string
      add :district, :string
      add :implementing_partner, :string
      add :project_manager, :string
      
      # M&E specific fields
      add :project_type, :string, null: false
      add :target_beneficiaries, :integer
      add :objectives, :text
      add :key_indicators, {:array, :text}

      timestamps()
    end

    create unique_index(:projects, [:project_code])
    create index(:projects, [:status])
    create index(:projects, [:project_type])
    create index(:projects, [:country])
    create index(:projects, [:start_date])
  end
end
