defmodule Ceec.CeecSurveys.Survey do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ceec_surveys" do
    # Personal Information
    field :first_name, :string
    field :last_name, :string
    field :national_id, :string
    field :date_of_birth, :date
    field :gender, :string
    field :marital_status, :string
    field :phone_number, :string
    field :email, :string
    field :postal_address, :string
    field :physical_address, :string
    field :district, :string
    field :province, :string

    # Education and Employment
    field :education_level, :string
    field :employment_status, :string
    field :current_occupation, :string
    field :monthly_income, :decimal

    # Business Information
    field :has_existing_business, :boolean, default: false
    field :business_name, :string
    field :business_type, :string
    field :business_sector, :string
    field :business_registration_number, :string
    field :years_in_business, :integer
    field :number_of_employees, :integer
    field :annual_turnover, :decimal

    # Funding Requirements
    field :funding_purpose, :string
    field :funding_amount_requested, :decimal
    field :funding_type_preferred, :string
    field :repayment_period_preferred, :integer
    field :collateral_available, :boolean, default: false
    field :collateral_type, :string
    field :collateral_value, :decimal

    # Banking and Financial
    field :has_bank_account, :boolean, default: false
    field :bank_name, :string
    field :account_number, :string
    field :previous_loan_experience, :boolean, default: false
    field :credit_score_rating, :string

    # Skills and Training
    field :business_skills_rating, :integer
    field :training_needs, {:array, :string}
    field :technical_skills, {:array, :string}
    field :requires_mentorship, :boolean, default: false

    # Additional Information
    field :has_disability, :boolean, default: false
    field :disability_type, :string
    field :dependents_count, :integer
    field :additional_notes, :string

    # Loan Follow-up Assessment
    field :has_received_loan, :boolean, default: false
    field :loan_disbursement_date, :date
    field :loan_amount_received, :decimal
    field :loan_usage_description, :string
    field :loan_usage_categories, {:array, :string}, default: []
    field :business_performance_rating, :integer
    field :employment_created, :integer
    field :monthly_revenue_change, :string
    field :loan_satisfaction_rating, :integer
    field :loan_repayment_status, :string
    field :loan_repayment_challenges, :string
    field :loan_impact_on_livelihood, :string
    field :requires_additional_support, :boolean, default: false
    field :additional_support_details, :string

    # Survey Metadata
    field :survey_status, :string, default: "draft"
    field :completion_percentage, :integer, default: 0
    field :submitted_at, :naive_datetime
    field :reviewed_at, :naive_datetime
    field :reviewer_id, :string
    field :approval_status, :string
    field :reference_number, :string

    timestamps()
  end

  @required_personal_fields ~w(first_name last_name national_id phone_number)a
  @optional_personal_fields ~w(date_of_birth gender marital_status email postal_address 
                               physical_address district province)a

  @optional_employment_fields ~w(education_level employment_status current_occupation monthly_income)a

  @optional_business_fields ~w(has_existing_business business_name business_type business_sector
                               business_registration_number years_in_business number_of_employees 
                               annual_turnover)a

  @optional_funding_fields ~w(funding_purpose funding_amount_requested funding_type_preferred
                              repayment_period_preferred collateral_available collateral_type 
                              collateral_value)a

  @optional_banking_fields ~w(has_bank_account bank_name account_number previous_loan_experience
                              credit_score_rating)a

  @optional_skills_fields ~w(business_skills_rating training_needs technical_skills requires_mentorship)a

  @optional_additional_fields ~w(has_disability disability_type dependents_count additional_notes)a

  @optional_post_loan_fields ~w(has_received_loan loan_disbursement_date loan_amount_received
                                loan_usage_description loan_usage_categories business_performance_rating
                                employment_created monthly_revenue_change loan_satisfaction_rating
                                loan_repayment_status loan_repayment_challenges loan_impact_on_livelihood
                                requires_additional_support additional_support_details)a

  @optional_metadata_fields ~w(survey_status completion_percentage submitted_at reviewed_at
                               reviewer_id approval_status reference_number)a

  @all_fields @required_personal_fields ++
                @optional_personal_fields ++
                @optional_employment_fields ++
                @optional_business_fields ++
                @optional_funding_fields ++
                @optional_banking_fields ++
                @optional_skills_fields ++
                @optional_additional_fields ++
                @optional_post_loan_fields ++
                @optional_metadata_fields

  @provinces [
    "Central",
    "Copperbelt",
    "Eastern",
    "Luapula",
    "Lusaka",
    "Muchinga",
    "Northern",
    "North-Western",
    "Southern",
    "Western"
  ]

  @education_levels [
    "Primary",
    "Secondary",
    "Certificate",
    "Diploma",
    "Bachelor's Degree",
    "Master's Degree",
    "Doctorate",
    "Other"
  ]

  @employment_statuses ["Employed", "Self-employed", "Unemployed", "Student", "Retired"]

  @business_sectors [
    "Agriculture",
    "Manufacturing",
    "Trade",
    "Services",
    "Tourism",
    "Construction",
    "Transport",
    "Mining",
    "ICT",
    "Other"
  ]

  @funding_types ["Loan", "Grant", "Equipment Financing", "Working Capital", "Asset Financing"]

  @gender_options ["Male", "Female", "Other", "Prefer not to say"]

  @marital_statuses ["Single", "Married", "Divorced", "Widowed", "Separated"]

  @loan_repayment_statuses ["On track", "Completed", "Behind schedule", "Not started"]
  @monthly_revenue_changes [
    "Increased significantly",
    "Increased slightly",
    "No change",
    "Decreased slightly",
    "Decreased significantly"
  ]
  @loan_usage_options [
    "Inventory & Stock",
    "Equipment Purchase",
    "Working Capital",
    "Marketing & Sales",
    "Staff Wages",
    "Expansion & Renovation",
    "Debt Repayment",
    "Other"
  ]

  def changeset(survey, attrs) do
    changeset =
      survey
      |> cast(attrs, @all_fields)
      |> validate_national_id()
      |> validate_phone_number()
      |> validate_email()
      |> validate_numeric_fields()
      |> validate_enums()
      |> validate_business_fields()
      |> validate_funding_fields()
      |> validate_banking_fields()
      |> validate_post_loan_fields()
      |> generate_reference_number()
      |> calculate_completion_percentage()
      |> unique_constraint(:national_id)
      |> unique_constraint(:reference_number)

    # Only require personal fields if survey is being submitted
    status = get_field(changeset, :survey_status)

    if status == "submitted" do
      changeset |> validate_required(@required_personal_fields)
    else
      changeset
    end
  end

  defp validate_national_id(changeset) do
    changeset
    |> validate_length(:national_id, min: 8, max: 15)
    |> validate_format(:national_id, ~r/^[0-9]+$/, message: "should contain only numbers")
  end

  defp validate_phone_number(changeset) do
    changeset
    |> validate_format(:phone_number, ~r/^(\+260|0)[0-9]{9}$/,
      message: "should be a valid Zambian phone number"
    )
  end

  defp validate_email(changeset) do
    changeset
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/, message: "should be a valid email")
  end

  defp validate_numeric_fields(changeset) do
    changeset
    |> validate_number(:monthly_income, greater_than_or_equal_to: 0)
    |> validate_number(:funding_amount_requested, greater_than: 0)
    |> validate_number(:annual_turnover, greater_than_or_equal_to: 0)
    |> validate_number(:collateral_value, greater_than_or_equal_to: 0)
    |> validate_number(:years_in_business, greater_than_or_equal_to: 0)
    |> validate_number(:number_of_employees, greater_than_or_equal_to: 0)
    |> validate_number(:dependents_count, greater_than_or_equal_to: 0)
    |> validate_number(:business_skills_rating,
      greater_than_or_equal_to: 1,
      less_than_or_equal_to: 5
    )
    |> validate_number(:loan_amount_received, greater_than: 0)
    |> validate_number(:employment_created, greater_than_or_equal_to: 0)
    |> validate_number(:business_performance_rating,
      greater_than_or_equal_to: 1,
      less_than_or_equal_to: 5
    )
    |> validate_number(:loan_satisfaction_rating,
      greater_than_or_equal_to: 1,
      less_than_or_equal_to: 5
    )
  end

  defp validate_enums(changeset) do
    changeset
    |> validate_inclusion(:province, @provinces)
    |> validate_inclusion(:education_level, @education_levels)
    |> validate_inclusion(:employment_status, @employment_statuses)
    |> validate_inclusion(:business_sector, @business_sectors)
    |> validate_inclusion(:funding_type_preferred, @funding_types)
    |> validate_inclusion(:gender, @gender_options)
    |> validate_inclusion(:marital_status, @marital_statuses)
    |> validate_inclusion(:loan_repayment_status, @loan_repayment_statuses)
    |> validate_inclusion(:monthly_revenue_change, @monthly_revenue_changes)
  end

  defp validate_business_fields(changeset) do
    has_business = get_field(changeset, :has_existing_business)

    if has_business do
      changeset
      |> validate_required([:business_name, :business_type, :business_sector])
    else
      changeset
    end
  end

  defp validate_funding_fields(changeset) do
    # Only validate funding fields if survey status is submitted
    status = get_field(changeset, :survey_status)

    if status == "submitted" do
      changeset
      |> validate_required([:funding_purpose, :funding_amount_requested, :funding_type_preferred])
    else
      changeset
    end
  end

  defp validate_banking_fields(changeset) do
    has_account = get_field(changeset, :has_bank_account)

    if has_account do
      changeset
      |> validate_required([:bank_name, :account_number])
    else
      changeset
    end
  end

  defp validate_post_loan_fields(changeset) do
    has_received_loan = get_field(changeset, :has_received_loan)

    changeset = validate_subset(changeset, :loan_usage_categories, @loan_usage_options)

    changeset =
      if has_received_loan do
        changeset
        |> validate_required([
          :loan_disbursement_date,
          :loan_amount_received,
          :loan_usage_description,
          :loan_repayment_status,
          :loan_satisfaction_rating
        ])
        |> validate_change(:loan_usage_categories, fn
          :loan_usage_categories, categories when is_list(categories) and categories != [] -> []
          :loan_usage_categories, _ -> [loan_usage_categories: "must select at least one option"]
        end)
      else
        changeset
      end

    if get_field(changeset, :requires_additional_support) do
      validate_required(changeset, [:additional_support_details])
    else
      changeset
    end
  end

  defp generate_reference_number(changeset) do
    if get_field(changeset, :reference_number) do
      changeset
    else
      ref_number =
        "CEEC-" <>
          Integer.to_string(:rand.uniform(999_999), 36) <>
          Integer.to_string(System.system_time(:second))

      put_change(changeset, :reference_number, ref_number)
    end
  end

  defp calculate_completion_percentage(changeset) do
    {filled_fields, total_important_fields} = count_filled_fields(changeset)
    total = if total_important_fields > 0, do: total_important_fields, else: 1
    percentage = min(round(filled_fields / total * 100), 100)
    put_change(changeset, :completion_percentage, percentage)
  end

  defp count_filled_fields(changeset) do
    base_fields = [
      :first_name,
      :last_name,
      :national_id,
      :phone_number,
      :province,
      :district,
      :education_level,
      :employment_status,
      :funding_purpose,
      :funding_amount_requested,
      :funding_type_preferred,
      :has_bank_account,
      :business_skills_rating,
      :requires_mentorship,
      :has_disability,
      :has_received_loan
    ]

    base_filled = Enum.count(base_fields, &field_filled?(changeset, &1))
    base_total = length(base_fields)

    if get_field(changeset, :has_received_loan) do
      loan_fields = [
        :loan_disbursement_date,
        :loan_amount_received,
        :loan_usage_description,
        :loan_usage_categories,
        :loan_repayment_status,
        :loan_satisfaction_rating,
        :loan_impact_on_livelihood
      ]

      loan_filled = Enum.count(loan_fields, &field_filled?(changeset, &1))
      {base_filled + loan_filled, base_total + length(loan_fields)}
    else
      {base_filled, base_total}
    end
  end

  defp field_filled?(changeset, field) do
    value = get_field(changeset, field)

    case value do
      nil -> false
      "" -> false
      [] -> false
      _ -> true
    end
  end

  def provinces, do: @provinces
  def education_levels, do: @education_levels
  def employment_statuses, do: @employment_statuses
  def business_sectors, do: @business_sectors
  def funding_types, do: @funding_types
  def gender_options, do: @gender_options
  def marital_statuses, do: @marital_statuses
  def loan_repayment_statuses, do: @loan_repayment_statuses
  def monthly_revenue_changes, do: @monthly_revenue_changes
  def loan_usage_options, do: @loan_usage_options
end
