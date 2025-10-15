alias Ceec.{Repo, Surveys, Projects, Accounts, Finance}
alias Ceec.Surveys.{Survey, SurveyQuestion}
alias Ceec.Projects.Project
alias Ceec.Accounts.User
alias Ceec.Finance.Loan

IO.puts("🌱 Creating Comprehensive Loan Application & Management Scenario...")

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

# Create diverse user base
IO.puts("👥 Creating diverse user base...")

# Existing borrowers with active loans
mary_consumer = create_user.("mary.banda@gmail.com", "mary123456789", "user")
john_consumer = create_user.("john.mwanza@gmail.com", "john123456789", "user") 
grace_consumer = create_user.("grace.phiri@gmail.com", "grace123456789", "user")
samuel_consumer = create_user.("samuel.zulu@gmail.com", "samuel123456789", "user")

# New loan applicants (pending applications)
patricia_applicant = create_user.("patricia.mulenga@gmail.com", "patricia123456789", "user")
joseph_applicant = create_user.("joseph.banda@gmail.com", "joseph123456789", "user")
sarah_applicant = create_user.("sarah.tembo@gmail.com", "sarah123456789", "user")
michael_applicant = create_user.("michael.phiri@gmail.com", "michael123456789", "user")

# Admin users
admin = create_user.("admin@ceec.com", "admin123456789", "admin")
loan_officer = create_user.("loanofficer@ceec.com", "loanofficer123456789", "admin")

# Create projects
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

{:ok, sme_project} = Projects.create_project(%{
  name: "SME Growth Program",
  project_code: "CEEC-SME-2024-005",
  project_id: "SME-005",
  description: "Small and medium enterprise development and expansion program",
  status: "active",
  start_date: ~D[2024-05-01],
  end_date: ~D[2027-04-30],
  budget: Decimal.new("10000000.00"),
  country: "Zambia",
  project_type: "Microfinance"
})

# Create EXISTING ACTIVE LOANS with proper associations
IO.puts("💳 Creating existing active loans...")

{:ok, mary_loan} = Finance.create_loan(%{
  loan_id: "WMI-LN-001",
  loan_type: "Microfinance",
  project_name: microfinance_project.name,
  project_id: microfinance_project.id,
  borrower_id: mary_consumer.id,
  amount: Decimal.new("150000"),
  interest_rate: Decimal.new("8.5"),
  maturity_date: ~D[2026-01-15],
  status: "Active",
  created_by: "Loan Officer",
  disbursed_at: ~U[2024-06-15 10:00:00Z]
})

{:ok, john_loan} = Finance.create_loan(%{
  loan_id: "SAS-LN-002",
  loan_type: "Agricultural", 
  project_name: agriculture_project.name,
  project_id: agriculture_project.id,
  borrower_id: john_consumer.id,
  amount: Decimal.new("300000"),
  interest_rate: Decimal.new("6.0"),
  maturity_date: ~D[2026-08-01],
  status: "Active",
  created_by: "Loan Officer",
  disbursed_at: ~U[2024-08-01 14:30:00Z]
})

{:ok, grace_loan} = Finance.create_loan(%{
  loan_id: "YED-LN-003",
  loan_type: "SME Loan",
  project_name: sme_project.name,
  project_id: sme_project.id,
  borrower_id: grace_consumer.id,
  amount: Decimal.new("75000"),
  interest_rate: Decimal.new("5.5"),
  maturity_date: ~D[2025-12-01],
  status: "Active",
  created_by: "Loan Officer",
  disbursed_at: ~U[2024-04-15 09:45:00Z]
})

{:ok, samuel_loan} = Finance.create_loan(%{
  loan_id: "AHI-LN-004",
  loan_type: "Housing",
  project_name: housing_project.name,
  project_id: housing_project.id,
  borrower_id: samuel_consumer.id,
  amount: Decimal.new("500000"),
  interest_rate: Decimal.new("4.5"),
  maturity_date: ~D[2029-04-01],
  status: "Active",
  created_by: "Loan Officer",
  disbursed_at: ~U[2024-10-01 11:15:00Z]
})

# Create PENDING LOAN APPLICATIONS
IO.puts("📋 Creating pending loan applications...")

{:ok, patricia_application} = Finance.create_loan(%{
  loan_id: "APP-WMI-005",
  loan_type: "Microfinance",
  borrower_id: patricia_applicant.id,
  amount: Decimal.new("200000"),
  interest_rate: Decimal.new("8.5"),
  maturity_date: ~D[2026-06-01],
  status: "Pending",
  created_by: "System Application",
  # Application details
  first_name: "Patricia",
  last_name: "Mulenga", 
  business_name: "Patricia's Fashion Boutique",
  phone: "+260977123456",
  email: "patricia.mulenga@gmail.com",
  nrc: "123456/78/1",
  business_type: "Retail",
  years_in_business: 3,
  purpose: "Expand clothing inventory and open second location",
  province: "Lusaka",
  district: "Lusaka",
  constituency: "Matero"
})

{:ok, joseph_application} = Finance.create_loan(%{
  loan_id: "APP-SAS-006",
  loan_type: "Agricultural",
  borrower_id: joseph_applicant.id,
  amount: Decimal.new("400000"),
  interest_rate: Decimal.new("6.0"),
  maturity_date: ~D[2026-12-01],
  status: "Pending",
  created_by: "System Application",
  first_name: "Joseph",
  last_name: "Banda",
  business_name: "Banda Family Farm",
  phone: "+260966789012",
  email: "joseph.banda@gmail.com",
  nrc: "234567/89/1",
  business_type: "Agriculture",
  years_in_business: 8,
  purpose: "Purchase new farming equipment and expand maize production",
  province: "Central",
  district: "Kabwe",
  constituency: "Bwacha"
})

{:ok, sarah_application} = Finance.create_loan(%{
  loan_id: "APP-YED-007",
  loan_type: "SME Loan",
  borrower_id: sarah_applicant.id,
  amount: Decimal.new("100000"),
  interest_rate: Decimal.new("5.5"),
  maturity_date: ~D[2025-10-01],
  status: "Pending",
  created_by: "System Application",
  first_name: "Sarah",
  last_name: "Tembo",
  business_name: "Tembo Beauty Salon",
  phone: "+260955345678",
  email: "sarah.tembo@gmail.com",
  nrc: "345678/90/1",
  business_type: "Beauty Services",
  years_in_business: 2,
  purpose: "Purchase professional hair equipment and salon furniture",
  province: "Copperbelt",
  district: "Ndola",
  constituency: "Wusakile"
})

{:ok, michael_application} = Finance.create_loan(%{
  loan_id: "APP-AHI-008",
  loan_type: "Housing",
  borrower_id: michael_applicant.id,
  amount: Decimal.new("800000"),
  interest_rate: Decimal.new("4.5"),
  maturity_date: ~D[2029-12-01],
  status: "Pending",
  created_by: "System Application",
  first_name: "Michael",
  last_name: "Phiri",
  business_name: "N/A",
  phone: "+260944456789",
  email: "michael.phiri@gmail.com",
  nrc: "456789/01/1",
  business_type: "N/A",
  years_in_business: 0,
  purpose: "Build family home with modern amenities",
  province: "Southern",
  district: "Choma",
  constituency: "Choma Central"
})

# Create project-specific surveys
IO.puts("📊 Creating project-specific surveys...")

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

{:ok, sme_survey} = Surveys.create_survey(%{
  title: "SME Growth Impact Survey",
  description: "Survey to measure the growth and development impact of SME loans on small business owners",
  status: "active",
  project_id: sme_project.id,
  created_by: "CEEC Admin",
  start_date: Date.utc_today(),
  end_date: Date.add(Date.utc_today(), 365)
})

# Add comprehensive survey questions
IO.puts("❓ Adding comprehensive survey questions...")

# Microfinance survey questions
Surveys.create_survey_question(%{
  survey_id: microfinance_survey.id,
  question_text: "How has the microfinance loan impacted your business revenue?",
  question_type: "radio",
  options: ["Increased significantly (>50%)", "Increased moderately (20-50%)", "Slight increase (<20%)", "No change", "Decreased"],
  required: true,
  order_index: 1
})

Surveys.create_survey_question(%{
  survey_id: microfinance_survey.id,
  question_text: "What challenges did you face in your business before receiving the loan?",
  question_type: "checkbox",
  options: ["Lack of working capital", "Limited inventory", "No equipment", "Poor business location", "Limited market access", "Other"],
  required: true,
  order_index: 2
})

# Agriculture survey questions  
Surveys.create_survey_question(%{
  survey_id: agriculture_survey.id,
  question_text: "How many hectares of land are you currently farming?",
  question_type: "select",
  options: ["Less than 1 hectare", "1-2 hectares", "3-5 hectares", "6-10 hectares", "More than 10 hectares"],
  required: true,
  order_index: 1
})

Surveys.create_survey_question(%{
  survey_id: agriculture_survey.id,
  question_text: "What is your estimated increase in crop yield since receiving the loan?",
  question_type: "text",
  required: true,
  order_index: 2
})

# Youth/SME survey questions
Surveys.create_survey_question(%{
  survey_id: youth_survey.id,
  question_text: "How many jobs has your business created since receiving the loan?",
  question_type: "select", 
  options: ["0", "1-2", "3-5", "6-10", "More than 10"],
  required: true,
  order_index: 1
})

# Housing survey questions
Surveys.create_survey_question(%{
  survey_id: housing_survey.id,
  question_text: "How would you rate your family's living conditions after the housing improvement?",
  question_type: "radio",
  options: ["Much better", "Somewhat better", "About the same", "Somewhat worse", "Much worse"],
  required: true,
  order_index: 1
})

# SME survey questions
Surveys.create_survey_question(%{
  survey_id: sme_survey.id,
  question_text: "What was your monthly business revenue before and after the loan?",
  question_type: "textarea",
  required: true,
  order_index: 1
})

IO.puts("")
IO.puts("✅ Successfully created Comprehensive Loan Scenario!")
IO.puts("")
IO.puts("🏢 PROJECTS WITH LOAN TYPES:")
IO.puts("   • Women's Microfinance Initiative → Microfinance loans")
IO.puts("   • Smallholder Agriculture Support → Agricultural loans")  
IO.puts("   • Youth Enterprise Development → SME loans")
IO.puts("   • Affordable Housing Initiative → Housing loans")
IO.puts("   • SME Growth Program → SME/Microfinance loans")
IO.puts("")
IO.puts("💳 ACTIVE LOANS (Disbursed):")
IO.puts("   • Mary Banda - K150,000 Microfinance (Active)")
IO.puts("   • John Mwanza - K300,000 Agricultural (Active)")
IO.puts("   • Grace Phiri - K75,000 SME (Active)")
IO.puts("   • Samuel Zulu - K500,000 Housing (Active)")
IO.puts("")
IO.puts("📋 PENDING APPLICATIONS:")
IO.puts("   • Patricia Mulenga - K200,000 Microfinance (Pending)")
IO.puts("   • Joseph Banda - K400,000 Agricultural (Pending)")
IO.puts("   • Sarah Tembo - K100,000 SME (Pending)")
IO.puts("   • Michael Phiri - K800,000 Housing (Pending)")
IO.puts("")
IO.puts("👥 USER ACCOUNTS:")
IO.puts("   🏦 Admin: admin@ceec.com / admin123456789")
IO.puts("   🏦 Loan Officer: loanofficer@ceec.com / loanofficer123456789")
IO.puts("   👩 Mary Banda: mary.banda@gmail.com / mary123456789 (Active Loan)")
IO.puts("   👨 John Mwanza: john.mwanza@gmail.com / john123456789 (Active Loan)")
IO.puts("   👩 Grace Phiri: grace.phiri@gmail.com / grace123456789 (Active Loan)")
IO.puts("   👨 Samuel Zulu: samuel.zulu@gmail.com / samuel123456789 (Active Loan)")
IO.puts("   👩 Patricia Mulenga: patricia.mulenga@gmail.com / patricia123456789 (Pending App)")
IO.puts("   👨 Joseph Banda: joseph.banda@gmail.com / joseph123456789 (Pending App)")
IO.puts("   👩 Sarah Tembo: sarah.tembo@gmail.com / sarah123456789 (Pending App)")
IO.puts("   👨 Michael Phiri: michael.phiri@gmail.com / michael123456789 (Pending App)")
IO.puts("")
IO.puts("🎯 COMPLETE WORKFLOW:")
IO.puts("   1. Users apply for loans → Pending status")
IO.puts("   2. Admin approves/processes → Active loans with project association")
IO.puts("   3. Borrowers take project-specific surveys for impact assessment")
IO.puts("   4. Loan types automatically map to appropriate projects")
IO.puts("")
IO.puts("📊 Each project has tailored survey questions for proper M&E!")