import Ecto.Query
alias Ceec.Surveys
alias Ceec.Finance

# Check active surveys
active_surveys = from(s in Surveys.Survey,
  where: s.status == "active",
  preload: [:project],
  order_by: [desc: s.inserted_at]
) |> Ceec.Repo.all()

IO.puts("=== ACTIVE SURVEYS ===")
IO.puts("Count: #{length(active_surveys)}")
active_surveys |> Enum.each(fn survey ->
  IO.puts("- ID: #{survey.id}, Title: #{survey.title}, Project: #{survey.project_id}")
end)

# Check loans
loans = Finance.list_loans()
IO.puts("\n=== LOANS ===")
IO.puts("Total loans: #{length(loans)}")

disbursed_loans = Enum.filter(loans, &(&1.status == "disbursed"))
IO.puts("Disbursed loans: #{length(disbursed_loans)}")

if length(disbursed_loans) > 0 do
  IO.puts("First disbursed loan:")
  loan = List.first(disbursed_loans)
  IO.puts("- ID: #{loan.id}, Status: #{loan.status}, Project: #{loan.project_id}")
end

# Test the lookup function
IO.puts("\n=== TEST LOOKUP ===")
if length(disbursed_loans) > 0 do
  loan = List.first(disbursed_loans)
  test_result = Finance.get_loan_by_application_id(to_string(loan.id))
  IO.puts("Test lookup for ID #{loan.id}: #{if test_result, do: "SUCCESS", else: "FAILED"}")
  
  # Check project matching
  IO.puts("\n=== PROJECT MATCHING ===")
  IO.puts("Loan ID #{loan.id} is in project #{loan.project_id}")
  
  matching_surveys = Enum.filter(active_surveys, &(&1.project_id == loan.project_id))
  IO.puts("Surveys available for this loan's project (#{loan.project_id}): #{length(matching_surveys)}")
  
  if length(matching_surveys) > 0 do
    IO.puts("Available survey IDs: #{matching_surveys |> Enum.map(& &1.id) |> Enum.join(", ")}")
  else
    IO.puts("No surveys match this loan's project!")
    IO.puts("All survey projects: #{active_surveys |> Enum.map(& &1.project_id) |> Enum.uniq() |> Enum.join(", ")}")
  end
end
