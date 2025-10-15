# Consumer Loan & Survey Scenario Seeds
# This creates a realistic scenario where consumers have existing loans and need to take project-specific surveys

alias Ceec.{Repo, Surveys, Projects, Accounts, Finance}
alias Ceec.Surveys.{Survey, SurveyQuestion}
alias Ceec.Projects.Project
alias Ceec.Accounts.User
alias Ceec.Finance.Loan

IO.puts("🌱 Creating Consumer Loan & Survey Scenario...")

# Helper function to create user if doesn't exist
create_user = fn email, password, role ->
  case Accounts.register_user(%{email: email, password: password, role: role}) do
    {:ok, user} -> 
      user = User.confirm_changeset(user) |> Repo.update!()
      IO.puts("   ✅ Created user: #{email}")
      user
    {:error, _} ->
      user = Accounts.get_user_by_email(email)
      IO.puts("   ⏭️  User exists: #{email}")
      user
  end
end

# Create consumer users (loan recipients)
IO.puts("👥 Creating consumer users...")

mary_consumer = create_user.("mary.banda@gmail.com", "mary123456789", "user")
john_consumer = create_user.("john.mwanza@gmail.com", "john123456789", "user") 
grace_consumer = create_user.("grace.phiri@gmail.com", "grace123456789", "user")
samuel_consumer = create_user.("samuel.zulu@gmail.com", "samuel123456789", "user")

# Create admin if doesn't exist
admin = create_user.("admin@ceec.com", "admin123456789", "admin")

# Create loan projects
IO.puts("🏢 Creating loan projects...")

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

# Create loans associated with projects
IO.puts("💳 Creating consumer loans linked to projects...")

{:ok, mary_loan} = Finance.create_loan(%{
  loan_id: "WMI-LN-001",
  project_name: microfinance_project.name,
  project_id: microfinance_project.id,
  borrower_id: mary_consumer.id,
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
  borrower_id: john_consumer.id,
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
  borrower_id: grace_consumer.id,
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
  borrower_id: samuel_consumer.id,
  amount: Decimal.new("500000"),
  interest_rate: Decimal.new("4.5"),
  maturity_date: ~D[2029-04-01],
  status: "Active",
  loan_type: "Housing",
  created_by: "CEEC Admin",
  borrower_name: "Samuel Zulu",
  borrower_contact: "samuel.zulu@gmail.com"
})

# Create project-specific surveys
IO.puts("📋 Creating project-specific surveys...")

{:ok, microfinance_survey} = Surveys.create_survey(%{
  title: "Women's Microfinance Impact Assessment",
  description: "Survey to assess the impact of microfinance loans on women entrepreneurs' businesses and livelihoods",
  status: "active",
  project_id: microfinance_project.id,
  created_by: "CEEC Admin",
  start_date: Date.utc_today(),
  end_date: Date.add(Date.utc_today(), 365)
})

{:ok, agriculture_survey} = Surveys.create_survey(%{
  title: "Agricultural Loan Impact Assessment",
  description: "Survey to evaluate the impact of agricultural loans on crop production, livestock, and farmer livelihoods",
  status: "active",
  project_id: agriculture_project.id,
  created_by: "CEEC Admin",
  start_date: Date.utc_today(),
  end_date: Date.add(Date.utc_today(), 365)
})

{:ok, youth_survey} = Surveys.create_survey(%{
  title: "Youth Enterprise Development Assessment",
  description: "Survey to assess the impact of business loans on young entrepreneurs and their enterprises",
  status: "active",
  project_id: youth_project.id,
  created_by: "CEEC Admin",
  start_date: Date.utc_today(),
  end_date: Date.add(Date.utc_today(), 365)
})

{:ok, housing_survey} = Surveys.create_survey(%{
  title: "Housing Loan Satisfaction Survey",
  description: "Survey to evaluate the impact of housing loans on family living conditions and community development",
  status: "active",
  project_id: housing_project.id,
  created_by: "CEEC Admin",
  start_date: Date.utc_today(),
  end_date: Date.add(Date.utc_today(), 365)
})

# Add survey questions
IO.puts("❓ Adding survey questions...")

# Microfinance survey questions
Surveys.create_survey_question(%{
  survey_id: microfinance_survey.id,
  question_text: "How has the microfinance loan impacted your business?",
  question_type: "textarea",
  required: true,
  order_index: 1
})

Surveys.create_survey_question(%{
  survey_id: microfinance_survey.id,
  question_text: "What did you use the loan for?",
  question_type: "checkbox",
  options: ["Inventory/Stock", "Equipment", "Business Expansion", "Working Capital", "Other"],
  required: true,
  order_index: 2
})

Surveys.create_survey_question(%{
  survey_id: microfinance_survey.id,
  question_text: "How would you rate your overall satisfaction with the loan process?",
  question_type: "radio",
  options: ["Very Satisfied", "Satisfied", "Neutral", "Dissatisfied", "Very Dissatisfied"],
  required: true,
  order_index: 3
})

# Agriculture survey questions
Surveys.create_survey_question(%{
  survey_id: agriculture_survey.id,
  question_text: "What crops did you grow with the agricultural loan?",
  question_type: "text",
  required: true,
  order_index: 1
})

Surveys.create_survey_question(%{
  survey_id: agriculture_survey.id,
  question_text: "How has your crop yield changed since receiving the loan?",
  question_type: "radio",
  options: ["Increased significantly", "Increased moderately", "No change", "Decreased moderately", "Decreased significantly"],
  required: true,
  order_index: 2
})

# Youth survey questions
Surveys.create_survey_question(%{
  survey_id: youth_survey.id,
  question_text: "What type of business did you start or expand?",
  question_type: "text",
  required: true,
  order_index: 1
})

Surveys.create_survey_question(%{
  survey_id: youth_survey.id,
  question_text: "How many people do you now employ in your business?",
  question_type: "select",
  options: ["0", "1-2", "3-5", "6-10", "More than 10"],
  required: true,
  order_index: 2
})

# Housing survey questions
Surveys.create_survey_question(%{
  survey_id: housing_survey.id,
  question_text: "How has the housing loan improved your living conditions?",
  question_type: "textarea",
  required: true,
  order_index: 1
})

Surveys.create_survey_question(%{
  survey_id: housing_survey.id,
  question_text: "What improvements did you make to your home?",
  question_type: "checkbox",
  options: ["New Construction", "Renovation", "Roofing", "Plumbing", "Electrical", "Other"],
  required: true,
  order_index: 2
})

IO.puts("")
IO.puts("✅ Successfully created Consumer Loan & Survey Scenario!")
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
IO.puts("👥 CONSUMER LOGIN CREDENTIALS:")
IO.puts("   👩 Mary Banda: mary.banda@gmail.com / mary123456789")
IO.puts("   👨 John Mwanza: john.mwanza@gmail.com / john123456789")
IO.puts("   👩 Grace Phiri: grace.phiri@gmail.com / grace123456789")
IO.puts("   👨 Samuel Zulu: samuel.zulu@gmail.com / samuel123456789")
IO.puts("")
IO.puts("🎥 SCENARIO: Each consumer can now take surveys related to their specific loan project!")
IO.puts("")
IO.puts("📋 HOW TO TEST:")
IO.puts("   1. Login as admin: admin@ceec.com / admin123456789")
IO.puts("   2. View loans at: http://localhost:4000/loans")
IO.puts("   3. Click 'Take Survey' button on any loan")
IO.puts("   4. Or login as consumer and visit their loan's survey")