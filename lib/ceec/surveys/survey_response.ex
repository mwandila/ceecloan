defmodule Ceec.Surveys.SurveyResponse do
  use Ecto.Schema
  import Ecto.Changeset

  schema "survey_responses" do
    # Basic respondent info (legacy - kept for compatibility)
    field :respondent_name, :string
    field :respondent_contact, :string
    field :respondent_location, :string
    field :survey_date, :date
    field :surveyor_name, :string
    
    # Visit Information
    field :visit_type, :string
    field :interviewer, :string  # legacy
    field :interviewer_name, :string  # new field
    field :visit_date, :date
    
    # Project Location
    field :province, :string
    field :district, :string
    field :constituency, :string
    field :gps_coordinates, :string
    
    # Beneficiary and Business Profile
    field :promoter_name, :string  # legacy
    field :beneficiary_name, :string
    field :beneficiary_id_number, :string
    field :beneficiary_phone, :string
    field :contact, :string  # legacy
    field :next_of_kin, :string
    field :gender, :string
    field :age, :integer
    field :business_name, :string
    field :years_in_business, :integer
    field :social_distribution, :string  # JSON string
    field :business_registration_status, :string
    field :business_type, :string
    
    # Funding and Project Details
    field :service_type, :string
    field :amount_disbursed, :decimal  # legacy
    field :loan_amount, :decimal
    field :loan_purpose, :string
    field :repayment_status, :string
    field :disbursement_date, :date
    field :purpose, :string
    field :empowerment_product, :string
    field :total_cost, :decimal
    field :beneficiary_contribution, :decimal
    
    # Economic Impact
    field :employees_before, :integer
    field :employees_after, :integer
    field :revenue_before, :decimal
    field :revenue_after, :decimal
    
    # Evaluation ratings
    field :project_rating, :integer
    field :impact_rating, :integer
    field :sustainability_rating, :integer
    
    # Legacy fields (kept for backward compatibility)
    field :project_name, :string
    field :implementing_organization, :string
    field :project_location, :string
    field :project_start_date, :date
    field :beneficiary_gender, :string  # legacy - now using :gender
    field :beneficiary_age, :integer  # legacy - now using :age
    field :household_size, :integer
    field :income_before, :decimal
    field :income_after, :decimal
    field :employment_status, :string
    field :skills_acquired, :string
    field :economic_impact, :string
    field :income_change_description, :string
    field :health_improvement, :string
    field :education_access, :string
    field :community_participation, :string
    field :sustainability_prospects, :string
    field :challenges_faced, :string
    field :recommendations, :string
    field :additional_comments, :string
    field :overall_satisfaction, :integer
    field :would_recommend, :boolean
    field :project_impact_rating, :string
    field :employment_impact, :string
    field :other_challenges, :string
    field :support_needed, :string
    
    belongs_to :survey, Ceec.Surveys.Survey
    belongs_to :loan, Ceec.Finance.Loan
    belongs_to :user, Ceec.Accounts.User
    
    field :completion_status, :string, default: "in_progress"
    field :submitted_at, :utc_datetime
    field :ip_address, :string
    field :user_agent, :string
    
    has_many :question_responses, Ceec.Surveys.QuestionResponse

    timestamps()
  end

  @doc false
  def changeset(survey_response, attrs) do
    survey_response
    |> cast(attrs, [
      # Basic respondent info (legacy)
      :respondent_name, :respondent_contact, :respondent_location, :survey_date, :surveyor_name,
      # Visit Information
      :visit_type, :interviewer, :interviewer_name, :visit_date,
      # Project Location
      :province, :district, :constituency, :gps_coordinates,
      # Beneficiary and Business Profile
      :promoter_name, :beneficiary_name, :beneficiary_id_number, :beneficiary_phone, :contact,
      :next_of_kin, :gender, :age, :business_name, :years_in_business,
      :social_distribution, :business_registration_status, :business_type,
      # Funding and Project Details
      :service_type, :amount_disbursed, :loan_amount, :loan_purpose, :repayment_status,
      :disbursement_date, :purpose, :empowerment_product, :total_cost, :beneficiary_contribution,
      # Economic Impact
      :employees_before, :employees_after, :revenue_before, :revenue_after,
      # Evaluation ratings
      :project_rating, :impact_rating, :sustainability_rating,
      # Legacy fields
      :project_name, :implementing_organization, :project_location, :project_start_date,
      :beneficiary_gender, :beneficiary_age, :household_size,
      :income_before, :income_after, :employment_status, :skills_acquired, :economic_impact, :income_change_description,
      :health_improvement, :education_access, :community_participation,
      :sustainability_prospects, :challenges_faced, :recommendations, :additional_comments,
      :overall_satisfaction, :would_recommend, :project_impact_rating, :employment_impact,
      :other_challenges, :support_needed,
      :survey_id, :loan_id, :user_id, :completion_status, :submitted_at, :ip_address, :user_agent
    ])
    |> validate_required([
      # Core required fields for stepper form
      :visit_type, :interviewer_name, :visit_date, :province, :district, :constituency,
      :beneficiary_name, :beneficiary_id_number, :beneficiary_phone, :gender, :age, :business_type,
      :survey_id
    ])
    |> validate_inclusion(:visit_type, ["monitoring", "evaluation"])
    |> validate_inclusion(:gender, ["male", "female", "other"])
    |> validate_inclusion(:business_type, ["retail", "agriculture", "manufacturing", "services", "other"])
    |> validate_number(:age, greater_than: 17, less_than: 101)
    |> maybe_validate_number(:years_in_business, greater_than_or_equal_to: 0)
    |> maybe_validate_number(:loan_amount, greater_than_or_equal_to: 0)
    |> maybe_validate_number(:amount_disbursed, greater_than_or_equal_to: 0)
    |> maybe_validate_number(:employees_before, greater_than_or_equal_to: 0)
    |> maybe_validate_number(:employees_after, greater_than_or_equal_to: 0)
    |> maybe_validate_number(:revenue_before, greater_than_or_equal_to: 0)
    |> maybe_validate_number(:revenue_after, greater_than_or_equal_to: 0)
    |> maybe_validate_number(:project_rating, greater_than_or_equal_to: 1, less_than_or_equal_to: 5)
    |> maybe_validate_number(:impact_rating, greater_than_or_equal_to: 1, less_than_or_equal_to: 5)
    |> maybe_validate_number(:sustainability_rating, greater_than_or_equal_to: 1, less_than_or_equal_to: 5)
    |> maybe_validate_number(:overall_satisfaction, greater_than_or_equal_to: 1, less_than_or_equal_to: 5)
    |> maybe_validate_number(:total_cost, greater_than_or_equal_to: 0)
    |> maybe_validate_number(:beneficiary_contribution, greater_than_or_equal_to: 0)
    |> process_social_distribution()
    |> foreign_key_constraint(:survey_id)
  end
  
  @doc """  
  Minimal changeset for creating survey responses for dynamic question-based surveys.
  Only requires the basic survey_id field.
  """
  def minimal_changeset(survey_response, attrs) do
    survey_response
    |> cast(attrs, [:survey_id, :loan_id, :user_id, :completion_status, :submitted_at, :ip_address, :user_agent])
    |> validate_required([:survey_id])
    |> foreign_key_constraint(:survey_id)
  end
  
  # Helper function to handle social_distribution array
  defp process_social_distribution(changeset) do
    case get_change(changeset, :social_distribution) do
      nil -> changeset
      distribution when is_list(distribution) ->
        put_change(changeset, :social_distribution, Jason.encode!(distribution))
      distribution when is_binary(distribution) ->
        changeset
    end
  end
  
  # Helper function to validate numbers only when present
  defp maybe_validate_number(changeset, field, opts) do
    value = get_change(changeset, field)
    if value != nil and value != "" do
      validate_number(changeset, field, opts)
    else
      changeset
    end
  end
end