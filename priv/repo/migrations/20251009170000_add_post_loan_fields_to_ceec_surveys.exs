defmodule Ceec.Repo.Migrations.AddPostLoanFieldsToCeecSurveys do
  use Ecto.Migration

  def change do
    alter table(:ceec_surveys) do
      add :has_received_loan, :boolean, default: false, null: false
      add :loan_disbursement_date, :date
      add :loan_amount_received, :decimal, precision: 15, scale: 2
      add :loan_usage_description, :text
      add :loan_usage_categories, {:array, :string}, default: []
      add :business_performance_rating, :integer
      add :employment_created, :integer
      add :monthly_revenue_change, :string
      add :loan_satisfaction_rating, :integer
      add :loan_repayment_status, :string
      add :loan_repayment_challenges, :text
      add :loan_impact_on_livelihood, :text
      add :requires_additional_support, :boolean, default: false, null: false
      add :additional_support_details, :text
    end

    create index(:ceec_surveys, [:has_received_loan])
    create index(:ceec_surveys, [:loan_repayment_status])
  end
end
