defmodule CeecWeb.Components.Sidebar do
  use Phoenix.Component
  alias Phoenix.LiveView.JS
  import CeecWeb.CoreComponents
  alias Ceec.Accounts.User

  @doc """
  Renders the main application sidebar
  """
  attr :current_user, User, default: nil
  attr :current_page, :string, default: ""

  def sidebar(assigns) do
    ~H"""
    <div id="sidebar" class="fixed inset-y-0 left-0 z-50 w-64 bg-gradient-to-b from-gray-900 to-gray-800 shadow-xl transform transition-transform duration-300 ease-in-out lg:translate-x-0">
      <!-- Sidebar Header -->
      <div class="flex items-center justify-between h-20 px-6 bg-gradient-to-r from-blue-600 to-indigo-600">
        <div class="flex items-center space-x-3">
          <div class="w-10 h-10 bg-white rounded-full flex items-center justify-center shadow-md">
            <svg class="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
            </svg>
          </div>
          <div class="text-white">
            <h2 class="text-lg font-bold">CEEC</h2>
            <p class="text-xs text-blue-100">Data Collection</p>
          </div>
        </div>
      </div>

      <!-- User Profile Section -->
      <div :if={@current_user} class="px-6 py-4 border-b border-gray-700">
        <div class="flex items-center space-x-3">
          <div class="w-10 h-10 bg-gradient-to-r from-blue-500 to-indigo-500 rounded-full flex items-center justify-center">
            <span class="text-white text-sm font-semibold">
              <%= String.first(@current_user.email) |> String.upcase() %>
            </span>
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-sm font-medium text-white truncate">
              <%= @current_user.email %>
            </p>
            <p class="text-xs text-gray-300">
              <%= User.role_name(@current_user) %>
            </p>
          </div>
        </div>
      </div>

      <!-- Navigation -->
      <nav class="mt-6 px-3">
        <div class="space-y-2">
          <!-- Dashboard -->
          <.nav_link 
            href="/" 
            active={@current_page == "dashboard"} 
            icon="home"
            label="Dashboard"
          />

          <!-- Surveys -->
          <.nav_link 
            href="/surveys" 
            active={@current_page == "surveys"} 
            icon="clipboard"
            label="Surveys"
          />

          <!-- Projects -->
          <.nav_link 
            href="/projects" 
            active={@current_page == "projects"} 
            icon="briefcase"
            label="Projects"
          />

          <!-- Loan Management -->
          <.nav_link 
            href="/loans" 
            active={@current_page == "loans"} 
            icon="credit-card"
            label="Loan Management"
          />

          <!-- Loan Applications Review -->
          <.nav_link 
            href="/admin/loan-applications" 
            active={@current_page == "loan-applications"} 
            icon="check-circle"
            label="Loan Applications"
          />

          <!-- Data Collection -->
          <.nav_link 
            href="/surveys/1/responses/new" 
            active={@current_page == "data-collection"} 
            icon="document"
            label="Data Collection"
          />

          <!-- Reports -->
          <.nav_link 
            href="/responses" 
            active={@current_page == "reports"} 
            icon="chart"
            label="Reports & Analytics"
          />

          <!-- Admin Section -->
          <div :if={@current_user && User.admin?(@current_user)} class="pt-4">
            <div class="px-3 mb-2">
              <h3 class="text-xs font-semibold text-gray-400 uppercase tracking-wider">
                Administration
              </h3>
            </div>
            
            <!-- User Management -->
            <.nav_link 
              href="/admin/users" 
              active={@current_page == "users"} 
              icon="users"
              label="User Management"
            />

            <!-- System Settings (Superadmin only) -->
            <.nav_link 
              :if={User.superadmin?(@current_user)}
              href="/admin/settings" 
              active={@current_page == "settings"} 
              icon="cog"
              label="System Settings"
            />
          </div>
        </div>
      </nav>

      <!-- Bottom Section -->
      <div class="absolute bottom-0 w-full p-4 border-t border-gray-700">
        <div class="flex items-center justify-between">
          <.link
            href="/users/settings"
            class="flex items-center space-x-2 text-gray-300 hover:text-white transition-colors duration-200"
          >
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path>
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
            </svg>
            <span class="text-sm">Settings</span>
          </.link>
          
          <.link
            href="/users/log_out"
            method="delete"
            class="flex items-center space-x-2 text-gray-300 hover:text-red-400 transition-colors duration-200"
          >
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path>
            </svg>
            <span class="text-sm">Logout</span>
          </.link>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders a navigation link with icon
  """
  attr :href, :string, required: true
  attr :active, :boolean, default: false
  attr :icon, :string, required: true
  attr :label, :string, required: true

  def nav_link(assigns) do
    ~H"""
    <.link
      href={@href}
      class={[
        "flex items-center space-x-3 px-3 py-2 rounded-lg text-sm font-medium transition-all duration-200 group",
        @active && "bg-blue-600 text-white shadow-lg",
        !@active && "text-gray-300 hover:bg-gray-700 hover:text-white"
      ]}
    >
      <.nav_icon name={@icon} active={@active} />
      <span>{@label}</span>
    </.link>
    """
  end

  @doc """
  Renders navigation icons
  """
  attr :name, :string, required: true
  attr :active, :boolean, default: false

  def nav_icon(%{name: "home"} = assigns) do
    ~H"""
    <svg class={["w-5 h-5", @active && "text-white", !@active && "text-gray-400 group-hover:text-white"]} fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"></path>
    </svg>
    """
  end

  def nav_icon(%{name: "clipboard"} = assigns) do
    ~H"""
    <svg class={["w-5 h-5", @active && "text-white", !@active && "text-gray-400 group-hover:text-white"]} fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"></path>
    </svg>
    """
  end

  def nav_icon(%{name: "briefcase"} = assigns) do
    ~H"""
    <svg class={["w-5 h-5", @active && "text-white", !@active && "text-gray-400 group-hover:text-white"]} fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2-2v2m8 0V6a2 2 0 012 2v6a2 2 0 01-2 2H6a2 2 0 01-2-2V8a2 2 0 012-2h8z"></path>
    </svg>
    """
  end

  def nav_icon(%{name: "credit-card"} = assigns) do
    ~H"""
    <svg class={["w-5 h-5", @active && "text-white", !@active && "text-gray-400 group-hover:text-white"]} fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"></path>
    </svg>
    """
  end

  def nav_icon(%{name: "document"} = assigns) do
    ~H"""
    <svg class={["w-5 h-5", @active && "text-white", !@active && "text-gray-400 group-hover:text-white"]} fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
    </svg>
    """
  end

  def nav_icon(%{name: "chart"} = assigns) do
    ~H"""
    <svg class={["w-5 h-5", @active && "text-white", !@active && "text-gray-400 group-hover:text-white"]} fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
    </svg>
    """
  end

  def nav_icon(%{name: "users"} = assigns) do
    ~H"""
    <svg class={["w-5 h-5", @active && "text-white", !@active && "text-gray-400 group-hover:text-white"]} fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z"></path>
    </svg>
    """
  end

  def nav_icon(%{name: "check-circle"} = assigns) do
    ~H"""
    <svg class={["w-5 h-5", @active && "text-white", !@active && "text-gray-400 group-hover:text-white"]} fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
    </svg>
    """
  end

  def nav_icon(%{name: "cog"} = assigns) do
    ~H"""
    <svg class={["w-5 h-5", @active && "text-white", !@active && "text-gray-400 group-hover:text-white"]} fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path>
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
    </svg>
    """
  end

  def nav_icon(assigns) do
    ~H"""
    <div class="w-5 h-5 bg-gray-400 rounded"></div>
    """
  end

  @doc """
  Renders mobile sidebar toggle button
  """
  def mobile_toggle(assigns) do
    ~H"""
    <button
      type="button"
      class="lg:hidden inline-flex items-center justify-center p-2 rounded-md text-gray-400 hover:text-white hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-white"
      phx-click={toggle_sidebar()}
    >
      <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
      </svg>
    </button>
    """
  end

  defp toggle_sidebar do
    JS.toggle(to: "#sidebar", in: "translate-x-0", out: "-translate-x-full")
  end
end