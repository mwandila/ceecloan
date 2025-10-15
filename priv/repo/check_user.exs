alias Ceec.Accounts

IO.puts("🔍 Checking Mary's account...")

user = Accounts.get_user_by_email("mary.banda@gmail.com")

if user do
  IO.puts("✅ User found:")
  IO.puts("   Email: #{user.email}")
  IO.puts("   Role: #{user.role}")
  IO.puts("   Confirmed at: #{user.confirmed_at}")
  IO.puts("   ID: #{user.id}")
  
  # Test password
  case Accounts.get_user_by_email_and_password("mary.banda@gmail.com", "mary123456789") do
    %Accounts.User{} = authenticated_user ->
      IO.puts("✅ Password authentication works!")
      IO.puts("   Authenticated user ID: #{authenticated_user.id}")
    nil ->
      IO.puts("❌ Password authentication failed!")
  end
else
  IO.puts("❌ User not found!")
end