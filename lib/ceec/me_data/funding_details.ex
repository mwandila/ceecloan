defmodule Ceec.MEData.FundingDetails do
  use Ecto.Schema
  import Ecto.Changeset

  schema "funding_details" do
    # Type of Service
    field :service_type, :string  # "loan", "grant", "both"
    
    # Loan Details
    field :loan_amount, :decimal
    field :loan_disbursement_date, :date
    field :loan_duration_months, :integer
    field :loan_interest_rate, :decimal
    field :loan_purpose, :string
    field :loan_repayment_frequency, :string  # "weekly", "monthly", "quarterly"
    
    # Grant Details
    field :grant_amount, :decimal
    field :grant_disbursement_date, :date
    field :grant_purpose, :string
    field :grant_type, :string  # "seed_funding", "equipment", "training", "other"
    
    # Empowerment Product (detailed CEEC list)
    field :empowerment_product, :string
    field :empowerment_category, :string
    field :empowerment_subcategory, :string
    
    # Project Cost Breakdown
    field :total_project_cost, :decimal
    field :ceec_contribution, :decimal
    field :beneficiary_contribution, :decimal
    field :other_contributions, :decimal
    field :contribution_sources, {:array, :string}
    
    # Disbursement History
    field :total_disbursed, :decimal
    field :number_of_disbursements, :integer
    field :last_disbursement_date, :date
    field :pending_disbursements, :decimal
    
    # Project Implementation
    field :project_start_date, :date
    field :expected_completion_date, :date
    field :actual_completion_date, :date
    field :implementation_status, :string  # "not_started", "in_progress", "completed", "delayed", "cancelled"
    field :completion_percentage, :integer, default: 0
    
    # Monitoring Details
    field :monitoring_frequency, :string  # "monthly", "quarterly", "bi_annual", "annual"
    field :last_monitoring_date, :date
    field :next_monitoring_date, :date
    
    # Additional Information
    field :special_conditions, :string
    field :collateral_required, :boolean, default: false
    field :collateral_type, :string
    field :guarantor_required, :boolean, default: false
    field :guarantor_details, :string
    
    # Relationships
    belongs_to :visit, Ceec.MEData.Visit

    timestamps()
  end

  @doc false
  def changeset(funding_details, attrs) do
    funding_details
    |> cast(attrs, [
      :service_type, :loan_amount, :loan_disbursement_date, :loan_duration_months,
      :loan_interest_rate, :loan_purpose, :loan_repayment_frequency, :grant_amount,
      :grant_disbursement_date, :grant_purpose, :grant_type, :empowerment_product,
      :empowerment_category, :empowerment_subcategory, :total_project_cost,
      :ceec_contribution, :beneficiary_contribution, :other_contributions,
      :contribution_sources, :total_disbursed, :number_of_disbursements,
      :last_disbursement_date, :pending_disbursements, :project_start_date,
      :expected_completion_date, :actual_completion_date, :implementation_status,
      :completion_percentage, :monitoring_frequency, :last_monitoring_date,
      :next_monitoring_date, :special_conditions, :collateral_required,
      :collateral_type, :guarantor_required, :guarantor_details, :visit_id
    ])
    |> validate_required([:service_type, :visit_id])
    |> validate_inclusion(:service_type, ["loan", "grant", "both"])
    |> validate_inclusion(:implementation_status, [
      "not_started", "in_progress", "completed", "delayed", "cancelled"
    ])
    |> validate_inclusion(:loan_repayment_frequency, [
      "weekly", "monthly", "quarterly", "bi_annual", "annual"
    ])
    |> validate_inclusion(:monitoring_frequency, [
      "monthly", "quarterly", "bi_annual", "annual"
    ])
    |> validate_number(:loan_amount, greater_than: 0)
    |> validate_number(:grant_amount, greater_than: 0)
    |> validate_number(:total_project_cost, greater_than: 0)
    |> validate_number(:completion_percentage, greater_than_or_equal_to: 0, less_than_or_equal_to: 100)
    |> validate_number(:loan_interest_rate, greater_than_or_equal_to: 0, less_than_or_equal_to: 100)
    |> foreign_key_constraint(:visit_id)
    |> validate_loan_details()
    |> validate_grant_details()
    |> calculate_total_contributions()
  end

  defp validate_loan_details(changeset) do
    service_type = get_field(changeset, :service_type)
    
    case service_type do
      type when type in ["loan", "both"] ->
        changeset
        |> validate_required([:loan_amount, :loan_purpose])
        |> validate_number(:loan_amount, greater_than: 0)
      _ -> changeset
    end
  end

  defp validate_grant_details(changeset) do
    service_type = get_field(changeset, :service_type)
    
    case service_type do
      type when type in ["grant", "both"] ->
        changeset
        |> validate_required([:grant_amount, :grant_purpose])
        |> validate_number(:grant_amount, greater_than: 0)
      _ -> changeset
    end
  end

  defp calculate_total_contributions(changeset) do
    ceec = get_field(changeset, :ceec_contribution) || Decimal.new(0)
    beneficiary = get_field(changeset, :beneficiary_contribution) || Decimal.new(0)
    other = get_field(changeset, :other_contributions) || Decimal.new(0)
    
    total = Decimal.add(ceec, Decimal.add(beneficiary, other))
    put_change(changeset, :total_project_cost, total)
  end

  @doc """
  Returns empowerment product categories used by CEEC
  """
  def empowerment_product_categories do
    %{
      "agriculture" => [
        "Crop Production",
        "Livestock Farming",
        "Aquaculture/Fish Farming",
        "Poultry Farming",
        "Horticulture",
        "Agro-processing",
        "Farm Equipment & Machinery"
      ],
      "manufacturing" => [
        "Food Processing",
        "Textiles & Clothing",
        "Furniture Making",
        "Metal Works",
        "Construction Materials",
        "Handicrafts & Crafts"
      ],
      "services" => [
        "Transport Services",
        "ICT Services",
        "Professional Services",
        "Financial Services",
        "Tourism & Hospitality",
        "Healthcare Services",
        "Education Services"
      ],
      "retail_trade" => [
        "General Retail",
        "Wholesale Trade",
        "Market Trading",
        "Shop/Store Operations",
        "Mobile Trading",
        "Online Business"
      ],
      "construction" => [
        "Building Construction",
        "Road Construction",
        "Plumbing Services",
        "Electrical Services",
        "Carpentry",
        "Masonry"
      ]
    }
  end

  @doc """
  Returns specific empowerment products for the Cashew sector
  """
  def cashew_empowerment_products do
    [
      {"Cashew Seedling Production", "cashew_seedlings"},
      {"Cashew Plantation Development", "cashew_plantation"},
      {"Cashew Nut Processing Equipment", "cashew_processing"},
      {"Cashew Value Addition", "cashew_value_addition"},
      {"Cashew Marketing & Distribution", "cashew_marketing"},
      {"Cashew Storage Facilities", "cashew_storage"},
      {"Cashew Quality Improvement", "cashew_quality"},
      {"Cashew Cooperative Development", "cashew_cooperative"}
    ]
  end

  @doc """
  Returns grant types available
  """
  def grant_types do
    [
      {"Seed Funding Grant", "seed_funding"},
      {"Equipment Grant", "equipment"},
      {"Training & Capacity Building Grant", "training"},
      {"Infrastructure Development Grant", "infrastructure"},
      {"Market Access Grant", "market_access"},
      {"Technology Upgrade Grant", "technology"},
      {"Working Capital Grant", "working_capital"},
      {"Other Grant", "other"}
    ]
  end
end