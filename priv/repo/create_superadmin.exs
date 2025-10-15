alias Ceec.{Accounts, Repo}
alias Ceec.Accounts.User

IO.puts("🔧 Creating superadmin user...")

case Accounts.register_user(%{email: "superadmin@ceec.com", password: "superadmin123456789", role: "superadmin"}) do
  {:ok, user} -> 
    user = User.confirm_changeset(user) |> Repo.update!()
    IO.puts("✅ Created superadmin: superadmin@ceec.com")
    IO.puts("🔑 Password: superadmin123456789")
  {:error, _} ->
    IO.puts("⏭️  Superadmin already exists: superadmin@ceec.com")
end