defmodule CeecWeb.AdminLive.Settings do
  use CeecWeb, :live_view
  import Ecto.Query
  alias Ceec.Accounts.User

  @impl true
  def mount(_params, _session, socket) do
    # Ensure only superadmins can access this page
    if socket.assigns.current_user && User.superadmin?(socket.assigns.current_user) do
      {:ok, 
       socket
       |> assign(page_title: "System Settings")
       |> assign_settings()}
    else
      {:ok, 
       socket
       |> put_flash(:error, "Access denied. Superadmin privileges required.")
       |> push_redirect(to: "/")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6">
      <.header>
        System Settings
        <:subtitle>Configure system-wide settings and preferences</:subtitle>
      </.header>

      <div class="mt-8 space-y-8">
        <!-- Application Settings -->
        <div class="bg-white shadow-sm rounded-lg divide-y divide-gray-200">
          <div class="px-6 py-4">
            <h3 class="text-lg font-medium text-gray-900 flex items-center">
              <svg class="w-5 h-5 mr-2 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path>
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
              </svg>
              Application Settings
            </h3>
            <p class="mt-1 text-sm text-gray-600">General application configuration</p>
          </div>
          
          <div class="px-6 py-4 space-y-4">
            <div class="grid grid-cols-1 gap-6 sm:grid-cols-2">
              <div>
                <label class="text-sm font-medium text-gray-700">Application Name</label>
                <p class="mt-1 text-sm text-gray-900 bg-gray-50 px-3 py-2 rounded-md">CEEC Data Collection Tool</p>
              </div>
              <div>
                <label class="text-sm font-medium text-gray-700">Version</label>
                <p class="mt-1 text-sm text-gray-900 bg-gray-50 px-3 py-2 rounded-md">1.0.0</p>
              </div>
              <div>
                <label class="text-sm font-medium text-gray-700">Environment</label>
                <p class="mt-1 text-sm text-gray-900 bg-gray-50 px-3 py-2 rounded-md">
                  <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                    <%= Mix.env() %>
                  </span>
                </p>
              </div>
              <div>
                <label class="text-sm font-medium text-gray-700">Elixir Version</label>
                <p class="mt-1 text-sm text-gray-900 bg-gray-50 px-3 py-2 rounded-md"><%= System.version() %></p>
              </div>
            </div>
          </div>
        </div>

        <!-- Database Settings -->
        <div class="bg-white shadow-sm rounded-lg divide-y divide-gray-200">
          <div class="px-6 py-4">
            <h3 class="text-lg font-medium text-gray-900 flex items-center">
              <svg class="w-5 h-5 mr-2 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4m0 5c0 2.21-3.582 4-8 4s8-1.79 8-4"></path>
              </svg>
              Database Information
            </h3>
            <p class="mt-1 text-sm text-gray-600">Database connection and statistics</p>
          </div>
          
          <div class="px-6 py-4 space-y-4">
            <div class="grid grid-cols-1 gap-6 sm:grid-cols-2">
              <div>
                <label class="text-sm font-medium text-gray-700">Total Users</label>
                <p class="mt-1 text-2xl font-bold text-gray-900">{@total_users}</p>
              </div>
              <div>
                <label class="text-sm font-medium text-gray-700">Active Users</label>
                <p class="mt-1 text-2xl font-bold text-green-600">{@confirmed_users}</p>
              </div>
              <div>
                <label class="text-sm font-medium text-gray-700">Administrators</label>
                <p class="mt-1 text-2xl font-bold text-blue-600">{@admin_users}</p>
              </div>
              <div>
                <label class="text-sm font-medium text-gray-700">Pending Users</label>
                <p class="mt-1 text-2xl font-bold text-yellow-600">{@pending_users}</p>
              </div>
            </div>
          </div>
        </div>

        <!-- System Status -->
        <div class="bg-white shadow-sm rounded-lg divide-y divide-gray-200">
          <div class="px-6 py-4">
            <h3 class="text-lg font-medium text-gray-900 flex items-center">
              <svg class="w-5 h-5 mr-2 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
              </svg>
              System Status
            </h3>
            <p class="mt-1 text-sm text-gray-600">Current system health and uptime</p>
          </div>
          
          <div class="px-6 py-4 space-y-4">
            <div class="grid grid-cols-1 gap-6 sm:grid-cols-2">
              <div>
                <label class="text-sm font-medium text-gray-700">Server Status</label>
                <p class="mt-1 flex items-center">
                  <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                    <svg class="w-3 h-3 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                    </svg>
                    Online
                  </span>
                </p>
              </div>
              <div>
                <label class="text-sm font-medium text-gray-700">Database Connection</label>
                <p class="mt-1 flex items-center">
                  <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                    <svg class="w-3 h-3 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                    </svg>
                    Connected
                  </span>
                </p>
              </div>
              <div>
                <label class="text-sm font-medium text-gray-700">Current Time</label>
                <p class="mt-1 text-sm text-gray-900 bg-gray-50 px-3 py-2 rounded-md">
                  <%= Calendar.strftime(DateTime.utc_now(), "%B %d, %Y at %I:%M %p UTC") %>
                </p>
              </div>
              <div>
                <label class="text-sm font-medium text-gray-700">Node Name</label>
                <p class="mt-1 text-sm text-gray-900 bg-gray-50 px-3 py-2 rounded-md font-mono text-xs">
                  <%= Node.self() %>
                </p>
              </div>
            </div>
          </div>
        </div>

        <!-- Quick Actions -->
        <div class="bg-white shadow-sm rounded-lg divide-y divide-gray-200">
          <div class="px-6 py-4">
            <h3 class="text-lg font-medium text-gray-900 flex items-center">
              <svg class="w-5 h-5 mr-2 text-indigo-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
              </svg>
              Quick Actions
            </h3>
            <p class="mt-1 text-sm text-gray-600">System administration shortcuts</p>
          </div>
          
          <div class="px-6 py-4">
            <div class="flex flex-wrap gap-4">
              <.link 
                navigate="/admin/users" 
                class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
              >
                <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z"></path>
                </svg>
                Manage Users
              </.link>
              
              <.link 
                navigate="/surveys" 
                class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
              >
                <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"></path>
                </svg>
                Manage Surveys
              </.link>
              
              <.link 
                navigate="/responses" 
                class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-purple-600 hover:bg-purple-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500"
              >
                <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
                </svg>
                View Reports
              </.link>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp assign_settings(socket) do
    socket
    |> assign(:total_users, count_total_users())
    |> assign(:confirmed_users, count_confirmed_users())
    |> assign(:admin_users, count_admin_users())
    |> assign(:pending_users, count_pending_users())
  end

  defp count_total_users do
    Ceec.Repo.aggregate(Ceec.Accounts.User, :count, :id)
  end

  defp count_confirmed_users do
    from(u in Ceec.Accounts.User, where: not is_nil(u.confirmed_at))
    |> Ceec.Repo.aggregate(:count, :id)
  end

  defp count_admin_users do
    from(u in Ceec.Accounts.User, where: u.role in ["admin", "superadmin"])
    |> Ceec.Repo.aggregate(:count, :id)
  end

  defp count_pending_users do
    from(u in Ceec.Accounts.User, where: is_nil(u.confirmed_at))
    |> Ceec.Repo.aggregate(:count, :id)
  end
end