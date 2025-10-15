defmodule Ceec.MEData.BusinessProfile do
  use Ecto.Schema
  import Ecto.Changeset

  schema "business_profiles" do
    # Promoter Information
    field :promoter_name, :string
    field :promoter_contact, :string
    field :promoter_email, :string
    field :next_of_kin_name, :string
    field :next_of_kin_contact, :string
    field :next_of_kin_relationship, :string
    
    # Social Distribution
    field :is_youth, :boolean, default: false
    field :is_woman, :boolean, default: false
    field :is_person_with_disability, :boolean, default: false
    field :social_category, {:array, :string}  # ["youth", "women", "pwd", "men"]
    
    # Business Registration
    field :is_business_registered, :boolean, default: false
    field :registration_reason, :string  # if not registered, why?
    
    # Statutory Body Registration (multiple selections)
    field :statutory_bodies, {:array, :string}  # ["PACRA", "ZRA", "ZABS", "CEEC", "etc."]
    field :pacra_registered, :boolean, default: false
    field :zra_registered, :boolean, default: false
    field :zabs_registered, :boolean, default: false
    field :ceec_registered, :boolean, default: false
    field :other_registrations, {:array, :string}
    
    # Business Type
    field :business_type, :string  # "sole_proprietor", "cooperative", "partnership", "limited_company"
    field :business_name, :string
    field :business_address, :string
    field :business_description, :string
    field :sector, :string  # "agriculture", "manufacturing", "services", "retail", etc.
    field :sub_sector, :string
    
    # Financial Management
    field :has_bank_account, :boolean, default: false
    field :bank_name, :string
    field :account_number, :string
    field :uses_mobile_money, :boolean, default: false
    field :mobile_money_providers, {:array, :string}  # ["MTN", "Airtel", "Zamtel"]
    
    # Business Operations
    field :years_in_operation, :integer
    field :number_of_branches, :integer, default: 1
    field :main_products_services, {:array, :string}
    field :target_market, :string
    field :seasonal_business, :boolean, default: false
    field :seasonal_months, {:array, :string}
    
    # Business Development
    field :has_business_plan, :boolean, default: false
    field :keeps_financial_records, :boolean, default: false
    field :record_keeping_method, :string  # "manual", "digital", "both", "none"
    
    # Relationships
    belongs_to :visit, Ceec.MEData.Visit

    timestamps()
  end

  @doc false
  def changeset(business_profile, attrs) do
    business_profile
    |> cast(attrs, [
      :promoter_name, :promoter_contact, :promoter_email, :next_of_kin_name,
      :next_of_kin_contact, :next_of_kin_relationship, :is_youth, :is_woman,
      :is_person_with_disability, :social_category, :is_business_registered,
      :registration_reason, :statutory_bodies, :pacra_registered, :zra_registered,
      :zabs_registered, :ceec_registered, :other_registrations, :business_type,
      :business_name, :business_address, :business_description, :sector, :sub_sector,
      :has_bank_account, :bank_name, :account_number, :uses_mobile_money,
      :mobile_money_providers, :years_in_operation, :number_of_branches,
      :main_products_services, :target_market, :seasonal_business, :seasonal_months,
      :has_business_plan, :keeps_financial_records, :record_keeping_method, :visit_id
    ])
    |> validate_required([:promoter_name, :visit_id])
    |> validate_inclusion(:business_type, [
      "sole_proprietor", "cooperative", "partnership", "limited_company", "other"
    ])
    |> validate_inclusion(:sector, [
      "agriculture", "manufacturing", "services", "retail", "construction", 
      "transport", "technology", "hospitality", "healthcare", "education", "other"
    ])
    |> validate_inclusion(:record_keeping_method, [
      "manual", "digital", "both", "none"
    ])
    |> validate_format(:promoter_email, ~r/^[^\s]+@[^\s]+$/, 
      message: "must be a valid email")
    |> validate_format(:promoter_contact, ~r/^\+?[\d\s\-\(\)]+$/, 
      message: "must be a valid phone number")
    |> validate_number(:years_in_operation, greater_than_or_equal_to: 0)
    |> validate_number(:number_of_branches, greater_than: 0)
    |> foreign_key_constraint(:visit_id)
    |> set_social_categories()
  end

  defp set_social_categories(changeset) do
    categories = []
    
    categories = if get_field(changeset, :is_youth), do: ["youth" | categories], else: categories
    categories = if get_field(changeset, :is_woman), do: ["women" | categories], else: categories
    categories = if get_field(changeset, :is_person_with_disability), do: ["pwd" | categories], else: categories
    
    # Add "men" if not woman (simplified logic)
    categories = if !get_field(changeset, :is_woman), do: ["men" | categories], else: categories
    
    put_change(changeset, :social_category, categories)
  end

  @doc """
  Returns available statutory bodies for registration
  """
  def statutory_bodies_options do
    [
      {"PACRA (Patents and Companies Registration Agency)", "PACRA"},
      {"ZRA (Zambia Revenue Authority)", "ZRA"},
      {"ZABS (Zambia Bureau of Standards)", "ZABS"},
      {"CEEC (Citizens Economic Empowerment Commission)", "CEEC"},
      {"ZDA (Zambia Development Agency)", "ZDA"},
      {"ZEMA (Zambia Environmental Management Agency)", "ZEMA"},
      {"Ministry of Commerce, Trade and Industry", "MCTI"},
      {"Local Council Business License", "LOCAL_COUNCIL"},
      {"Professional Body Registration", "PROFESSIONAL"},
      {"Other", "OTHER"}
    ]
  end

  @doc """
  Returns available mobile money providers
  """
  def mobile_money_providers_options do
    [
      {"MTN Mobile Money", "MTN"},
      {"Airtel Money", "AIRTEL"},
      {"Zamtel Kwacha", "ZAMTEL"}
    ]
  end

  @doc """
  Returns business type options
  """
  def business_type_options do
    [
      {"Sole Proprietorship", "sole_proprietor"},
      {"Cooperative", "cooperative"},
      {"Partnership", "partnership"},
      {"Limited Company", "limited_company"},
      {"Other", "other"}
    ]
  end
end