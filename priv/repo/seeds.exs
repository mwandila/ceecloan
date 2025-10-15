# Script for populating the database with sample CEEC-style M&E data
# This simulates a real-world scenario where consumers have loans and need to take surveys

alias Ceec.{Repo, Surveys, Projects, Accounts, Finance}
alias Ceec.Surveys.{Survey, SurveyQuestion}
alias Ceec.Projects.Project
alias Ceec.Accounts.User
alias Ceec.Finance.Loan

# Clear existing data
IO.puts("🌱 Seeding CEEC Consumer Loan & Survey System...")
IO.puts("📋 Creating realistic scenario: Consumers with existing loans need to take project-specific surveys")

# Create admin and superadmin users
IO.puts("👤 Creating admin users...")

# Create superadmin user (skip if exists)
superadmin = case Accounts.register_user(%{
  email: "superadmin@ceec.com",
  password: "superadmin123456",
  role: "superadmin"
}) do
  {:ok, user} -> user
  {:error, _} -> Accounts.get_user_by_email("superadmin@ceec.com")
end

# Confirm the superadmin user
superadmin = User.confirm_changeset(superadmin) |> Repo.update!()

# Create admin user (skip if exists)
admin = case Accounts.register_user(%{
  email: "admin@ceec.com",
  password: "admin123456789",
  role: "admin"
}) do
  {:ok, user} -> user
  {:error, _} -> Accounts.get_user_by_email("admin@ceec.com")
end

# Confirm the admin user
admin = User.confirm_changeset(admin) |> Repo.update!()

# Create sample regular user (skip if exists)
regular_user = case Accounts.register_user(%{
  email: "user@ceec.com",
  password: "user123456789",
  role: "user"
}) do
  {:ok, user} -> user
  {:error, _} -> Accounts.get_user_by_email("user@ceec.com")
end

# Confirm the regular user
regular_user = User.confirm_changeset(regular_user) |> Repo.update!()

# Create consumer users (loan recipients)
IO.puts("👥 Creating consumer users (loan recipients)...")

mary_consumer = case Accounts.register_user(%{
  email: "mary.banda@gmail.com",
  password: "mary123456789",
  role: "user"
}) do
  {:ok, user} -> user
  {:error, _} -> Accounts.get_user_by_email("mary.banda@gmail.com")
end
mary_consumer = User.confirm_changeset(mary_consumer) |> Repo.update!()

john_consumer = case Accounts.register_user(%{
  email: "john.mwanza@gmail.com", 
  password: "john123456789",
  role: "user"
}) do
  {:ok, user} -> user
  {:error, _} -> Accounts.get_user_by_email("john.mwanza@gmail.com")
end
john_consumer = User.confirm_changeset(john_consumer) |> Repo.update!()

grace_consumer = case Accounts.register_user(%{
  email: "grace.phiri@gmail.com",
  password: "grace123456789",
  role: "user"
}) do
  {:ok, user} -> user
  {:error, _} -> Accounts.get_user_by_email("grace.phiri@gmail.com")
end
grace_consumer = User.confirm_changeset(grace_consumer) |> Repo.update!()

samuel_consumer = case Accounts.register_user(%{
  email: "samuel.zulu@gmail.com",
  password: "samuel123456789",
  role: "user"
}) do
  {:ok, user} -> user
  {:error, _} -> Accounts.get_user_by_email("samuel.zulu@gmail.com")
end
samuel_consumer = User.confirm_changeset(samuel_consumer) |> Repo.update!()

# Create loan projects first
IO.puts("🏢 Creating loan projects...")

# Create projects that will have associated loans and surveys
{:ok, microfinance_project} = Projects.create_project(%{
  name: "Women's Microfinance Initiative",
  project_code: "CEEC-WMI-2024-001",
  project_id: "WMI-001",
  description: "Microfinance program for women entrepreneurs in rural areas",
  status: "active",
  start_date: ~D[2024-01-01],
  end_date: ~D[2026-12-31], 
  budget: Decimal.new("5000000.00"),
  country: "Zambia",
  project_type: "Microfinance"
})

{:ok, agriculture_project} = Projects.create_project(%{
  name: "Smallholder Agriculture Support",
  project_code: "CEEC-SAS-2024-002",
  project_id: "SAS-002",
  description: "Support program for smallholder farmers with crop production and livestock",
  status: "active",
  start_date: ~D[2024-02-01],
  end_date: ~D[2027-01-31],
  budget: Decimal.new("8000000.00"),
  country: "Zambia",
  project_type: "Agriculture"
})

{:ok, youth_project} = Projects.create_project(%{
  name: "Youth Enterprise Development",
  project_code: "CEEC-YED-2024-003",
  project_id: "YED-003",
  description: "Business development program for young entrepreneurs",
  status: "active",
  start_date: ~D[2024-03-01], 
  end_date: ~D[2026-02-28],
  budget: Decimal.new("3000000.00"),
  country: "Zambia",
  project_type: "Youth Development"
})

{:ok, housing_project} = Projects.create_project(%{
  name: "Affordable Housing Initiative",
  project_code: "CEEC-AHI-2024-004",
  project_id: "AHI-004",
  description: "Housing loan program for low-income families",
  status: "active",
  start_date: ~D[2024-04-01],
  end_date: ~D[2029-03-31],
  budget: Decimal.new("15000000.00"),
  country: "Zambia",
  project_type: "Housing"
})

# Create loans associated with projects for our consumer users
IO.puts("💳 Creating consumer loans linked to projects...")

{:ok, mary_loan} = Finance.create_loan(%{
  loan_id: "WMI-LN-001",
  project_name: microfinance_project.name,
  project_id: microfinance_project.id,
  amount: Decimal.new("150000"),
  interest_rate: Decimal.new("8.5"),
  maturity_date: ~D[2026-01-15],
  status: "Active",
  loan_type: "Microfinance",
  created_by: "CEEC Admin",
  borrower_name: "Mary Banda",
  borrower_contact: "mary.banda@gmail.com"
})

{:ok, john_loan} = Finance.create_loan(%{
  loan_id: "SAS-LN-002",
  project_name: agriculture_project.name,
  project_id: agriculture_project.id,
  amount: Decimal.new("300000"),
  interest_rate: Decimal.new("6.0"),
  maturity_date: ~D[2026-08-01],
  status: "Active",
  loan_type: "Agricultural",
  created_by: "CEEC Admin",
  borrower_name: "John Mwanza",
  borrower_contact: "john.mwanza@gmail.com"
})

{:ok, grace_loan} = Finance.create_loan(%{
  loan_id: "YED-LN-003",
  project_name: youth_project.name,
  project_id: youth_project.id,
  amount: Decimal.new("75000"),
  interest_rate: Decimal.new("5.5"),
  maturity_date: ~D[2025-12-01],
  status: "Active",
  loan_type: "SME Loan",
  created_by: "CEEC Admin",
  borrower_name: "Grace Phiri",
  borrower_contact: "grace.phiri@gmail.com"
})

{:ok, samuel_loan} = Finance.create_loan(%{
  loan_id: "AHI-LN-004",
  project_name: housing_project.name,
  project_id: housing_project.id,
  amount: Decimal.new("500000"),
  interest_rate: Decimal.new("4.5"),
  maturity_date: ~D[2029-04-01],
  status: "Active",
  loan_type: "Housing",
  created_by: "CEEC Admin",
  borrower_name: "Samuel Zulu",
  borrower_contact: "samuel.zulu@gmail.com"
})

# Create project-specific surveys that consumers will need to complete
IO.puts("📋 Creating project-specific surveys for loan recipients...")

# Survey for Women's Microfinance Initiative
{:ok, microfinance_survey} = Surveys.create_survey(%{
  title: "Women's Microfinance Impact Assessment",
  description: "Survey to assess the impact of microfinance loans on women entrepreneurs' businesses and livelihoods",
  status: "active",
  project_id: microfinance_project.id,
  created_by: "CEEC Admin",
  start_date: Date.utc_today(),
  end_date: Date.add(Date.utc_today(), 365)
})

# Survey for Smallholder Agriculture Support 
{:ok, agriculture_survey} = Surveys.create_survey(%{
  title: "Agricultural Loan Impact Assessment",
  description: "Survey to evaluate the impact of agricultural loans on crop production, livestock, and farmer livelihoods",
  status: "active",
  project_id: agriculture_project.id,
  created_by: "CEEC Admin",
  start_date: Date.utc_today(),
  end_date: Date.add(Date.utc_today(), 365)
})

# Survey for Youth Enterprise Development
{:ok, youth_survey} = Surveys.create_survey(%{
  title: "Youth Enterprise Development Assessment",
  description: "Survey to assess the impact of business loans on young entrepreneurs and their enterprises",
  status: "active",
  project_id: youth_project.id,
  created_by: "CEEC Admin",
  start_date: Date.utc_today(),
  end_date: Date.add(Date.utc_today(), 365)
})

# Survey for Affordable Housing Initiative
{:ok, housing_survey} = Surveys.create_survey(%{
  title: "Housing Loan Satisfaction Survey",
  description: "Survey to evaluate the impact of housing loans on family living conditions and community development",
  status: "active",
  project_id: housing_project.id,
  created_by: "CEEC Admin",
  start_date: Date.utc_today(),
  end_date: Date.add(Date.utc_today(), 365)
})

# Add survey questions for each survey
IO.puts("❓ Adding survey questions...")

# Add questions to microfinance survey using survey builder format
Surveys.create_survey_question(%{
  survey_id: microfinance_survey.id,
  question_text: "How has the microfinance loan impacted your business?",
  question_type: "textarea",
  required: true,
  order_index: 1,
  category: "impact",
  help_text: "Please describe specific changes in your business operations, revenue, or growth"
})

Surveys.create_survey_question(%{
  survey_id: microfinance_survey.id,
  question_text: "What did you use the loan for?",
  question_type: "checkbox",
  options: %{
    "choices" => ["Inventory/Stock", "Equipment", "Business Expansion", "Working Capital", "Other"]
  },
  required: true,
  order_index: 2,
  category: "loan_usage"
})

Surveys.create_survey_question(%{
  survey_id: microfinance_survey.id,
  question_text: "How would you rate your overall satisfaction with the loan process?",
  question_type: "rating",
  options: %{
    "max_value" => 5,
    "labels" => ["Very Dissatisfied", "Dissatisfied", "Neutral", "Satisfied", "Very Satisfied"]
  },
  required: true,
  order_index: 3,
  category: "satisfaction"
})

Surveys.create_survey_question(%{
  survey_id: microfinance_survey.id,
  question_text: "What was your approximate monthly revenue before the loan? (ZMW)",
  question_type: "number",
  required: true,
  order_index: 4,
  category: "impact"
})

Surveys.create_survey_question(%{
  survey_id: microfinance_survey.id,
  question_text: "What is your approximate monthly revenue now? (ZMW)",
  question_type: "number",
  required: true,
  order_index: 5,
  category: "impact"
})

# Add questions to agriculture survey using survey builder format
Surveys.create_survey_question(%{
  survey_id: agriculture_survey.id,
  question_text: "What crops did you grow with the agricultural loan?",
  question_type: "checkbox",
  options: %{
    "choices" => ["Maize", "Soya beans", "Groundnuts", "Sunflower", "Vegetables", "Rice", "Wheat", "Other"]
  },
  required: true,
  order_index: 1,
  category: "loan_usage"
})

Surveys.create_survey_question(%{
  survey_id: agriculture_survey.id,
  question_text: "How has your crop yield changed since receiving the loan?",
  question_type: "radio",
  options: %{
    "choices" => ["Increased significantly", "Increased moderately", "No change", "Decreased moderately", "Decreased significantly"]
  },
  required: true,
  order_index: 2,
  category: "impact"
})

Surveys.create_survey_question(%{
  survey_id: agriculture_survey.id,
  question_text: "What farming equipment or inputs did you purchase?",
  question_type: "checkbox",
  options: %{
    "choices" => ["Seeds/Seedlings", "Fertilizer", "Pesticides", "Farming Tools", "Irrigation Equipment", "Processing Equipment", "Other"]
  },
  required: true,
  order_index: 3,
  category: "loan_usage"
})

Surveys.create_survey_question(%{
  survey_id: agriculture_survey.id,
  question_text: "Rate your satisfaction with the agricultural support provided",
  question_type: "rating",
  options: %{
    "max_value" => 5,
    "labels" => ["Very Dissatisfied", "Dissatisfied", "Neutral", "Satisfied", "Very Satisfied"]
  },
  required: true,
  order_index: 4,
  category: "satisfaction"
})

# Add questions to youth survey using survey builder format
Surveys.create_survey_question(%{
  survey_id: youth_survey.id,
  question_text: "What type of business did you start or expand?",
  question_type: "select",
  options: %{
    "choices" => ["Retail/Trading", "Manufacturing", "Technology/ICT", "Agriculture", "Services", "Food & Beverage", "Fashion & Beauty", "Other"]
  },
  required: true,
  order_index: 1,
  category: "business_profile"
})

Surveys.create_survey_question(%{
  survey_id: youth_survey.id,
  question_text: "How many people do you now employ in your business?",
  question_type: "select",
  options: %{
    "choices" => ["0", "1-2", "3-5", "6-10", "More than 10"]
  },
  required: true,
  order_index: 2,
  category: "impact"
})

Surveys.create_survey_question(%{
  survey_id: youth_survey.id,
  question_text: "What was your biggest challenge in starting/expanding your business?",
  question_type: "checkbox",
  options: %{
    "choices" => ["Access to capital", "Market competition", "Lack of experience", "Finding customers", "Regulatory requirements", "Location/space", "Other"]
  },
  required: false,
  order_index: 3,
  category: "challenges"
})

Surveys.create_survey_question(%{
  survey_id: youth_survey.id,
  question_text: "Rate the impact of this loan on your business growth",
  question_type: "rating",
  options: %{
    "max_value" => 5,
    "labels" => ["Very Negative", "Negative", "Neutral", "Positive", "Very Positive"]
  },
  required: true,
  order_index: 4,
  category: "impact"
})

# Add questions to housing survey using survey builder format
Surveys.create_survey_question(%{
  survey_id: housing_survey.id,
  question_text: "How has the housing loan improved your living conditions?",
  question_type: "textarea",
  required: true,
  order_index: 1,
  category: "impact",
  help_text: "Please describe specific improvements in your family's quality of life"
})

Surveys.create_survey_question(%{
  survey_id: housing_survey.id,
  question_text: "What improvements did you make to your home?",
  question_type: "checkbox",
  options: %{
    "choices" => ["New Construction", "Renovation", "Roofing", "Plumbing", "Electrical", "Flooring", "Windows/Doors", "Other"]
  },
  required: true,
  order_index: 2,
  category: "loan_usage"
})

Surveys.create_survey_question(%{
  survey_id: housing_survey.id,
  question_text: "How many family members benefited from this housing improvement?",
  question_type: "number",
  required: true,
  order_index: 3,
  category: "impact"
})

Surveys.create_survey_question(%{
  survey_id: housing_survey.id,
  question_text: "How satisfied are you with the housing loan terms and process?",
  question_type: "rating",
  options: %{
    "max_value" => 5,
    "labels" => ["Very Dissatisfied", "Dissatisfied", "Neutral", "Satisfied", "Very Satisfied"]
  },
  required: true,
  order_index: 4,
  category: "satisfaction"
})

IO.puts("✅ Successfully seeded CEEC Consumer Loan & Survey System!")
IO.puts("")
IO.puts("🏢 PROJECTS CREATED:")
IO.puts("   • Women's Microfinance Initiative (WMI-001)")
IO.puts("   • Smallholder Agriculture Support (SAS-002)")
IO.puts("   • Youth Enterprise Development (YED-003)")
IO.puts("   • Affordable Housing Initiative (AHI-004)")
IO.puts("")
IO.puts("💳 CONSUMER LOANS CREATED:")
IO.puts("   • Mary Banda - K150,000 Microfinance Loan (WMI-LN-001)")
IO.puts("   • John Mwanza - K300,000 Agricultural Loan (SAS-LN-002)")
IO.puts("   • Grace Phiri - K75,000 Youth Enterprise Loan (YED-LN-003)")
IO.puts("   • Samuel Zulu - K500,000 Housing Loan (AHI-LN-004)")
IO.puts("")
IO.puts("📋 PROJECT-SPECIFIC SURVEYS:")
IO.puts("   • Women's Microfinance Impact Assessment")
IO.puts("   • Agricultural Loan Impact Assessment")
IO.puts("   • Youth Enterprise Development Assessment")
IO.puts("   • Housing Loan Satisfaction Survey")
IO.puts("")
IO.puts("🔑 LOGIN CREDENTIALS:")
IO.puts("   👑 Superadmin: superadmin@ceec.com / superadmin123456")
IO.puts("   🛠️  Admin: admin@ceec.com / admin123456789")
IO.puts("")
IO.puts("👥 CONSUMER LOGIN CREDENTIALS:")
IO.puts("   👩 Mary Banda: mary.banda@gmail.com / mary123456789")
IO.puts("   👨 John Mwanza: john.mwanza@gmail.com / john123456789")
IO.puts("   👩 Grace Phiri: grace.phiri@gmail.com / grace123456789")
IO.puts("   👨 Samuel Zulu: samuel.zulu@gmail.com / samuel123456789")
IO.puts("")
IO.puts("🎥 SCENARIO: Each consumer can now take surveys related to their specific loan project!")
IO.puts("")
IO.puts("🌐 ADMIN ACCESS:")
IO.puts("   📋 Surveys: http://localhost:4000/surveys")
IO.puts("   🏢 Projects: http://localhost:4000/projects")
IO.puts("   💳 Loans: http://localhost:4000/loans")
IO.puts("   🏗️ Survey Builder: http://localhost:4000/surveys/builder/new")
IO.puts("")
IO.puts("📋 CONSUMER SURVEY ACCESS:")
IO.puts("   Visit loan page and click 'Take Survey' button")
IO.puts("   Or go directly to: http://localhost:4000/loans/[loan_id]/survey")
