defmodule Ceec.MEData.EmploymentRecord do
  use Ecto.Schema
  import Ecto.Changeset

  schema "employment_records" do
    # Employment Type
    field :employment_type, :string  # "permanent", "seasonal", "temporary", "casual"
    
    # Time Period (Before or After loan/grant)
    field :period, :string  # "before", "after"
    field :reference_date, :date  # Date of loan disbursement or project start
    
    # Social Group Breakdown
    field :youth_male_count, :integer, default: 0
    field :youth_female_count, :integer, default: 0
    field :adult_male_count, :integer, default: 0
    field :adult_female_count, :integer, default: 0
    field :pwd_male_count, :integer, default: 0      # Persons with Disabilities - Male
    field :pwd_female_count, :integer, default: 0    # Persons with Disabilities - Female
    
    # Total Calculations
    field :total_male, :integer, default: 0
    field :total_female, :integer, default: 0
    field :total_youth, :integer, default: 0
    field :total_adults, :integer, default: 0
    field :total_pwd, :integer, default: 0
    field :grand_total, :integer, default: 0
    
    # Employment Details
    field :average_wage_male, :decimal
    field :average_wage_female, :decimal
    field :working_hours_per_day, :integer
    field :working_days_per_week, :integer
    field :working_weeks_per_year, :integer
    
    # Seasonal Information (if applicable)
    field :seasonal_months, {:array, :string}
    field :peak_employment_months, {:array, :string}
    field :off_season_employment, :boolean, default: false
    
    # Skills and Training
    field :skill_level_required, :string  # "unskilled", "semi_skilled", "skilled", "professional"
    field :training_provided, :boolean, default: false
    field :training_type, {:array, :string}
    field :training_duration_days, :integer
    
    # Employment Benefits
    field :provides_benefits, :boolean, default: false
    field :benefit_types, {:array, :string}  # ["medical", "transport", "meals", "accommodation"]
    field :has_employment_contracts, :boolean, default: false
    
    # Notes and Additional Information
    field :employment_notes, :string
    field :challenges_faced, :string
    field :future_employment_plans, :string
    
    # Relationships
    belongs_to :visit, Ceec.MEData.Visit

    timestamps()
  end

  @doc false
  def changeset(employment_record, attrs) do
    employment_record
    |> cast(attrs, [
      :employment_type, :period, :reference_date, :youth_male_count, :youth_female_count,
      :adult_male_count, :adult_female_count, :pwd_male_count, :pwd_female_count,
      :total_male, :total_female, :total_youth, :total_adults, :total_pwd, :grand_total,
      :average_wage_male, :average_wage_female, :working_hours_per_day, :working_days_per_week,
      :working_weeks_per_year, :seasonal_months, :peak_employment_months, :off_season_employment,
      :skill_level_required, :training_provided, :training_type, :training_duration_days,
      :provides_benefits, :benefit_types, :has_employment_contracts, :employment_notes,
      :challenges_faced, :future_employment_plans, :visit_id
    ])
    |> validate_required([:employment_type, :period, :visit_id])
    |> validate_inclusion(:employment_type, ["permanent", "seasonal", "temporary", "casual"])
    |> validate_inclusion(:period, ["before", "after"])
    |> validate_inclusion(:skill_level_required, ["unskilled", "semi_skilled", "skilled", "professional"])
    |> validate_number(:youth_male_count, greater_than_or_equal_to: 0)
    |> validate_number(:youth_female_count, greater_than_or_equal_to: 0)
    |> validate_number(:adult_male_count, greater_than_or_equal_to: 0)
    |> validate_number(:adult_female_count, greater_than_or_equal_to: 0)
    |> validate_number(:pwd_male_count, greater_than_or_equal_to: 0)
    |> validate_number(:pwd_female_count, greater_than_or_equal_to: 0)
    |> validate_number(:working_hours_per_day, greater_than: 0, less_than_or_equal_to: 24)
    |> validate_number(:working_days_per_week, greater_than: 0, less_than_or_equal_to: 7)
    |> validate_number(:working_weeks_per_year, greater_than: 0, less_than_or_equal_to: 52)
    |> validate_number(:training_duration_days, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:visit_id)
    |> calculate_totals()
  end

  defp calculate_totals(changeset) do
    youth_male = get_field(changeset, :youth_male_count) || 0
    youth_female = get_field(changeset, :youth_female_count) || 0
    adult_male = get_field(changeset, :adult_male_count) || 0
    adult_female = get_field(changeset, :adult_female_count) || 0
    pwd_male = get_field(changeset, :pwd_male_count) || 0
    pwd_female = get_field(changeset, :pwd_female_count) || 0

    total_male = youth_male + adult_male + pwd_male
    total_female = youth_female + adult_female + pwd_female
    total_youth = youth_male + youth_female
    total_adults = adult_male + adult_female
    total_pwd = pwd_male + pwd_female
    grand_total = total_male + total_female

    changeset
    |> put_change(:total_male, total_male)
    |> put_change(:total_female, total_female)
    |> put_change(:total_youth, total_youth)
    |> put_change(:total_adults, total_adults)
    |> put_change(:total_pwd, total_pwd)
    |> put_change(:grand_total, grand_total)
  end

  @doc """
  Returns employment summary comparing before and after periods
  """
  def employment_impact(before_records, after_records) do
    before_total = Enum.sum(Enum.map(before_records, & &1.grand_total))
    after_total = Enum.sum(Enum.map(after_records, & &1.grand_total))
    
    before_female = Enum.sum(Enum.map(before_records, & &1.total_female))
    after_female = Enum.sum(Enum.map(after_records, & &1.total_female))
    
    before_youth = Enum.sum(Enum.map(before_records, & &1.total_youth))
    after_youth = Enum.sum(Enum.map(after_records, & &1.total_youth))
    
    before_pwd = Enum.sum(Enum.map(before_records, & &1.total_pwd))
    after_pwd = Enum.sum(Enum.map(after_records, & &1.total_pwd))

    %{
      total_employment_change: after_total - before_total,
      female_employment_change: after_female - before_female,
      youth_employment_change: after_youth - before_youth,
      pwd_employment_change: after_pwd - before_pwd,
      employment_growth_percentage: 
        if(before_total > 0, 
          do: Float.round((after_total - before_total) / before_total * 100, 1), 
          else: 100)
    }
  end

  @doc """
  Returns benefit types available
  """
  def benefit_types_options do
    [
      {"Medical/Health Insurance", "medical"},
      {"Transport Allowance", "transport"},
      {"Meals/Food Allowance", "meals"},
      {"Accommodation", "accommodation"},
      {"Pension/Retirement Benefits", "pension"},
      {"Training & Development", "training"},
      {"Paid Leave", "paid_leave"},
      {"Overtime Pay", "overtime"},
      {"Performance Bonuses", "bonuses"}
    ]
  end

  @doc """
  Returns training types available
  """
  def training_types_options do
    [
      {"On-the-job Training", "on_job"},
      {"Technical Skills Training", "technical"},
      {"Safety Training", "safety"},
      {"Quality Control Training", "quality"},
      {"Leadership Training", "leadership"},
      {"Financial Literacy", "financial"},
      {"Business Skills", "business"},
      {"Digital/Computer Skills", "digital"},
      {"Language Training", "language"}
    ]
  end

  @doc """
  Returns months of the year for seasonal employment
  """
  def months_options do
    [
      {"January", "january"}, {"February", "february"}, {"March", "march"},
      {"April", "april"}, {"May", "may"}, {"June", "june"},
      {"July", "july"}, {"August", "august"}, {"September", "september"},
      {"October", "october"}, {"November", "november"}, {"December", "december"}
    ]
  end
end