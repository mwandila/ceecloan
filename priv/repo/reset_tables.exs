alias Ceec.Repo

IO.puts("🗑️ Clearing all tables...")

# Clear in order of dependencies
Repo.delete_all(Ceec.Surveys.SurveyQuestion)
Repo.delete_all(Ceec.Surveys.Survey)
Repo.delete_all(Ceec.Finance.Loan)
Repo.delete_all(Ceec.Projects.Project)
Repo.delete_all(Ceec.Accounts.User)

IO.puts("✅ All tables cleared!")