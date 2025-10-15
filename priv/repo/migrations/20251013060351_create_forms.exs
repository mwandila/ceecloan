defmodule Ceec.Repo.Migrations.CreateForms do
  use Ecto.Migration

  def change do
    create table(:forms) do
      add :name, :string, null: false
      add :description, :text
      add :form_type, :string, null: false
      add :version, :string, default: "1.0"
      add :status, :string, default: "draft"
      add :language, :string, default: "en"
      
      # Form configuration stored as JSON
      add :form_schema, :map
      add :settings, :map
      
      # Metadata
      add :created_by, :string, null: false
      add :tags, {:array, :string}
      
      add :project_id, references(:projects, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:forms, [:project_id])
    create index(:forms, [:form_type])
    create index(:forms, [:status])
    create index(:forms, [:created_by])
  end
end
