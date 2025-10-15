defmodule CeecWeb.UserLoginLive do
  use CeecWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-blue-50 via-white to-indigo-100 flex items-center justify-center py-12 px-4">
      <div class="w-full max-w-md">
        <!-- Main Card -->
        <div class="bg-white rounded-3xl shadow-2xl p-8 border border-gray-100">
          <!-- Header Section -->
          <div class="text-center mb-8">
            <!-- Logo -->
            <div class="mx-auto w-20 h-20 bg-gradient-to-r from-blue-500 to-indigo-600 rounded-full flex items-center justify-center mb-6 shadow-lg">
              <svg class="w-10 h-10 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
              </svg>
            </div>
            
            <!-- Title -->
            <h1 class="text-3xl font-bold text-gray-900 mb-3">Welcome Back</h1>
            <p class="text-gray-600 text-sm">
              Don't have an account?
              <.link navigate={~p"/users/register"} class="text-blue-600 hover:text-blue-500 font-medium transition-colors">
                Sign up for free
              </.link>
            </p>
            <div class="mt-4 p-4 bg-blue-50 rounded-xl border border-blue-200">
              <p class="text-blue-800 text-sm font-medium mb-2">Looking for a loan?</p>
              <.link navigate={~p"/loans/apply"} class="inline-flex items-center px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium rounded-lg transition-colors duration-200">
                <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                </svg>
                Apply for Loan
              </.link>
            </div>
          </div>

          <!-- Form -->
          <form action={~p"/users/log_in"} method="post" id="login_form" phx-update="ignore" class="space-y-6">
            <input type="hidden" name="_csrf_token" value={Phoenix.Controller.get_csrf_token()} />
            
            <!-- Email Field -->
            <div class="space-y-2">
              <label for="user_email" class="block text-sm font-medium text-gray-700">Email Address</label>
              <div class="relative">
                <input
                  id="user_email"
                  name="user[email]"
                  type="email"
                  value={@form[:email].value || ""}
                  class="w-full px-4 py-3 rounded-xl border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all duration-200 bg-gray-50 focus:bg-white"
                  placeholder="Enter your email address"
                  required
                  autocomplete="email"
                />
                <div class="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none">
                  <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.207"></path>
                  </svg>
                </div>
              </div>
              <%= if @form[:email].errors != [] do %>
                <div class="text-red-600 text-sm flex items-center mt-1">
                  <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                  </svg>
                  <%= Enum.map(@form[:email].errors, fn {msg, _} -> msg end) |> Enum.join(", ") %>
                </div>
              <% end %>
            </div>

            <!-- Password Field -->
            <div class="space-y-2">
              <label for="user_password" class="block text-sm font-medium text-gray-700">Password</label>
              <div class="relative">
                <input
                  id="user_password"
                  name="user[password]"
                  type="password"
                  class="w-full px-4 py-3 rounded-xl border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all duration-200 bg-gray-50 focus:bg-white"
                  placeholder="Enter your password"
                  required
                  autocomplete="current-password"
                />
                <div class="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none">
                  <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
                  </svg>
                </div>
              </div>
              <%= if @form[:password].errors != [] do %>
                <div class="text-red-600 text-sm flex items-center mt-1">
                  <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                  </svg>
                  <%= Enum.map(@form[:password].errors, fn {msg, _} -> msg end) |> Enum.join(", ") %>
                </div>
              <% end %>
            </div>

            <!-- Remember Me & Forgot Password -->
            <div class="flex items-center justify-between">
              <div class="flex items-center">
                <input
                  id="user_remember_me"
                  name="user[remember_me]"
                  type="checkbox"
                  class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                />
                <label for="user_remember_me" class="ml-2 text-sm text-gray-700">
                  Keep me signed in
                </label>
              </div>
              <.link href={~p"/users/reset_password"} class="text-sm text-blue-600 hover:text-blue-500 font-medium transition-colors">
                Forgot password?
              </.link>
            </div>

            <!-- Submit Button -->
            <button 
              type="submit" 
              class="w-full bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 text-white font-semibold py-3 px-6 rounded-xl transition-all duration-200 transform hover:scale-[1.02] active:scale-[0.98] shadow-lg hover:shadow-xl flex items-center justify-center space-x-2"
              phx-disable-with="Signing in..."
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1"></path>
              </svg>
              <span>Sign In to CEEC</span>
            </button>
          </form>

          <!-- Footer -->
          <div class="mt-8 pt-6 border-t border-gray-200">
            <p class="text-center text-xs text-gray-500">
              CEEC Data Collection Tool
            </p>
          </div>
        </div>

        <!-- Floating decorative elements -->
        <div class="absolute top-10 left-10 w-20 h-20 bg-blue-200 rounded-full mix-blend-multiply filter blur-xl opacity-70 animate-pulse"></div>
        <div class="absolute top-40 right-10 w-32 h-32 bg-indigo-200 rounded-full mix-blend-multiply filter blur-xl opacity-70 animate-pulse" style="animation-delay: 2s;"></div>
        <div class="absolute bottom-20 left-20 w-24 h-24 bg-purple-200 rounded-full mix-blend-multiply filter blur-xl opacity-70 animate-pulse" style="animation-delay: 4s;"></div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
