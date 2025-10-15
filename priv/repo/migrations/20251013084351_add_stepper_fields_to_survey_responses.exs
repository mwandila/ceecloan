defmodule Ceec.Repo.Migrations.AddStepperFieldsToSurveyResponses do
  use Ecto.Migration

  def change do
    alter table(:survey_responses) do
      # Step 1: Visit Information - rename interviewer to interviewer_name
      add :interviewer_name, :string
      
      # Step 3: Beneficiary Information
      add :beneficiary_id_number, :string
      add :beneficiary_phone, :string
      add :gender, :string
      add :age, :integer
      add :business_name, :string
      add :years_in_business, :integer
      
      # Step 4: Funding Details
      add :loan_amount, :decimal
      add :loan_purpose, :string
      add :repayment_status, :string
      
      # Step 5: Economic Impact
      add :employees_before, :integer
      add :employees_after, :integer
      add :revenue_before, :decimal
      add :revenue_after, :decimal
      
      # Step 6: Evaluation
      add :project_rating, :integer
      add :impact_rating, :integer
      add :sustainability_rating, :integer
    end

    # Create indexes for commonly queried fields
    create index(:survey_responses, [:beneficiary_phone])
    create index(:survey_responses, [:gender])
    create index(:survey_responses, [:business_type])
    create index(:survey_responses, [:loan_purpose])
    create index(:survey_responses, [:repayment_status])
  end
end
