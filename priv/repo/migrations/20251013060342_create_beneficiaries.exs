defmodule Ceec.Repo.Migrations.CreateBeneficiaries do
  use Ecto.Migration

  def change do
    create table(:beneficiaries) do
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :identifier, :string, null: false
      add :phone_number, :string
      add :email, :string
      add :date_of_birth, :date
      add :gender, :string, null: false
      add :marital_status, :string
      
      # Location information
      add :address, :text
      add :village, :string
      add :district, :string
      add :region, :string
      add :gps_latitude, :decimal, precision: 10, scale: 8
      add :gps_longitude, :decimal, precision: 11, scale: 8
      
      # Socio-economic information
      add :education_level, :string
      add :occupation, :string
      add :household_size, :integer
      add :monthly_income, :decimal, precision: 15, scale: 2
      add :has_disability, :boolean, default: false
      add :disability_type, :string
      
      # Project-specific fields
      add :enrollment_date, :date, null: false
      add :status, :string, null: false, default: "active"
      add :category, :string
      
      # Additional metadata
      add :notes, :text
      add :profile_photo_url, :string
      
      add :project_id, references(:projects, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:beneficiaries, [:identifier])
    create index(:beneficiaries, [:project_id])
    create index(:beneficiaries, [:status])
    create index(:beneficiaries, [:gender])
    create index(:beneficiaries, [:enrollment_date])
    create index(:beneficiaries, [:first_name, :last_name])
  end
end
