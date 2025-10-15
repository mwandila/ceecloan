defmodule Ceec.Repo.Migrations.UpdateSurveyResponsesWithNewFields do
  use Ecto.Migration

  def change do
    alter table(:survey_responses) do
      # Visit Information fields
      add_if_not_exists :visit_type, :string
      add_if_not_exists :interviewer, :string
      add_if_not_exists :visit_date, :date
      
      # Project Location fields
      add_if_not_exists :province, :string
      add_if_not_exists :district, :string
      add_if_not_exists :constituency, :string
      add_if_not_exists :gps_coordinates, :string
      
      # Beneficiary and Business Profile fields
      add_if_not_exists :promoter_name, :string
      add_if_not_exists :contact, :string
      add_if_not_exists :next_of_kin, :string
      add_if_not_exists :social_distribution, :text  # JSON array
      add_if_not_exists :business_registration_status, :string
      add_if_not_exists :business_type, :string
      
      # Funding and Project Details fields
      add_if_not_exists :service_type, :string
      add_if_not_exists :amount_disbursed, :decimal, precision: 15, scale: 2
      add_if_not_exists :disbursement_date, :date
      add_if_not_exists :purpose, :text
      add_if_not_exists :empowerment_product, :string
      add_if_not_exists :total_cost, :decimal, precision: 15, scale: 2
      add_if_not_exists :beneficiary_contribution, :decimal, precision: 15, scale: 2
    end
  end
end
