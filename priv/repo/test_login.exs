alias Ceec.Accounts

IO.puts("🧪 Testing login flow...")

# Test all users
users = [
  {"mary.banda@gmail.com", "mary123456789"},
  {"john.mwanza@gmail.com", "john123456789"},
  {"grace.phiri@gmail.com", "grace123456789"},
  {"samuel.zulu@gmail.com", "samuel123456789"},
  {"admin@ceec.com", "admin123456789"},
  {"superadmin@ceec.com", "superadmin123456789"}
]

Enum.each(users, fn {email, password} ->
  IO.puts("\n🔍 Testing: #{email}")
  
  case Accounts.get_user_by_email_and_password(email, password) do
    %Accounts.User{} = user ->
      IO.puts("✅ Login successful")
      IO.puts("   ID: #{user.id}")
      IO.puts("   Role: #{user.role}")
      IO.puts("   Confirmed: #{user.confirmed_at}")
    nil ->
      IO.puts("❌ Login failed")
      
      # Check if user exists
      if user = Accounts.get_user_by_email(email) do
        IO.puts("   User exists but password is wrong")
        IO.puts("   Confirmed: #{user.confirmed_at}")
      else
        IO.puts("   User doesn't exist")
      end
  end
end)