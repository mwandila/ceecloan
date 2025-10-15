defmodule Ceec.Repo.Migrations.CreateFormSubmissions do
  use Ecto.Migration

  def change do
    create table(:form_submissions) do
      add :submission_id, :string, null: false
      add :data, :map, null: false
      add :status, :string, default: "draft"
      add :submitted_at, :utc_datetime
      add :reviewed_at, :utc_datetime
      add :reviewed_by, :string
      
      # Location data
      add :gps_latitude, :decimal, precision: 10, scale: 8
      add :gps_longitude, :decimal, precision: 11, scale: 8
      add :gps_accuracy, :decimal, precision: 8, scale: 2
      add :location_address, :string
      
      # Data collector information
      add :collector_name, :string, null: false
      add :collector_id, :string
      add :device_id, :string
      
      # Quality control
      add :validation_errors, {:array, :string}
      add :quality_score, :integer
      add :notes, :text
      
      # Offline sync support
      add :created_offline, :boolean, default: false
      add :synced_at, :utc_datetime
      
      add :form_id, references(:forms, on_delete: :delete_all), null: false
      add :project_id, references(:projects, on_delete: :delete_all), null: false
      add :beneficiary_id, references(:beneficiaries, on_delete: :nilify_all)

      timestamps()
    end

    create unique_index(:form_submissions, [:submission_id])
    create index(:form_submissions, [:form_id])
    create index(:form_submissions, [:project_id])
    create index(:form_submissions, [:beneficiary_id])
    create index(:form_submissions, [:status])
    create index(:form_submissions, [:submitted_at])
    create index(:form_submissions, [:collector_name])
  end
end
