defmodule Ceec.Repo.Migrations.CreateCeecSurveys do
  use Ecto.Migration

  def change do
    create table(:ceec_surveys) do
      # Personal Information
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :national_id, :string, null: false
      add :date_of_birth, :date
      add :gender, :string
      add :marital_status, :string
      add :phone_number, :string, null: false
      add :email, :string
      add :postal_address, :text
      add :physical_address, :text
      add :district, :string
      add :province, :string

      # Education and Employment
      add :education_level, :string
      add :employment_status, :string
      add :current_occupation, :string
      add :monthly_income, :decimal, precision: 15, scale: 2

      # Business Information
      add :has_existing_business, :boolean, default: false
      add :business_name, :string
      add :business_type, :string
      add :business_sector, :string
      add :business_registration_number, :string
      add :years_in_business, :integer
      add :number_of_employees, :integer
      add :annual_turnover, :decimal, precision: 15, scale: 2

      # Funding Requirements
      add :funding_purpose, :string
      add :funding_amount_requested, :decimal, precision: 15, scale: 2
      add :funding_type_preferred, :string
      add :repayment_period_preferred, :integer
      add :collateral_available, :boolean, default: false
      add :collateral_type, :string
      add :collateral_value, :decimal, precision: 15, scale: 2

      # Banking and Financial
      add :has_bank_account, :boolean, default: false
      add :bank_name, :string
      add :account_number, :string
      add :previous_loan_experience, :boolean, default: false
      add :credit_score_rating, :string

      # Skills and Training
      add :business_skills_rating, :integer
      add :training_needs, {:array, :string}
      add :technical_skills, {:array, :string}
      add :requires_mentorship, :boolean, default: false

      # Additional Information
      add :has_disability, :boolean, default: false
      add :disability_type, :string
      add :dependents_count, :integer
      add :additional_notes, :text

      # Survey Metadata
      add :survey_status, :string, default: "draft"
      add :completion_percentage, :integer, default: 0
      add :submitted_at, :naive_datetime
      add :reviewed_at, :naive_datetime
      add :reviewer_id, :string
      add :approval_status, :string
      add :reference_number, :string

      timestamps()
    end

    create unique_index(:ceec_surveys, [:national_id])
    create unique_index(:ceec_surveys, [:reference_number])
    create index(:ceec_surveys, [:survey_status])
    create index(:ceec_surveys, [:province, :district])
    create index(:ceec_surveys, [:funding_type_preferred])
    create index(:ceec_surveys, [:business_sector])
  end
end
