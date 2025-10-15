defmodule CeecWeb.UserLive.FormComponent do
  use CeecWeb, :live_component

  alias Ceec.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage user records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="user-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input 
          :if={@action == :new}
          field={@form[:password]} 
          type="password" 
          label="Password" 
          placeholder="Must be at least 12 characters"
          required 
        />
        <.input 
          field={@form[:role]} 
          type="select" 
          label="Role" 
          options={[
            {"User", "user"}, 
            {"Administrator", "admin"}, 
            {"Super Administrator", "superadmin"}
          ]}
          required
        />
        <div :if={@action == :edit} class="mt-4 p-4 bg-gray-50 rounded-lg">
          <h4 class="text-sm font-medium text-gray-900 mb-2">Account Status</h4>
          <div class="flex items-center space-x-4">
            <div class="text-sm text-gray-600">
              <strong>Confirmed:</strong> 
              <%= if @user.confirmed_at do %>
                <span class="text-green-600">Yes</span> (<%= Calendar.strftime(@user.confirmed_at, "%b %d, %Y at %I:%M %p") %>)
              <% else %>
                <span class="text-yellow-600">Pending</span>
              <% end %>
            </div>
          </div>
        </div>
        <:actions>
          <.button phx-disable-with="Saving..." class="bg-blue-600 hover:bg-blue-700">Save User</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{user: user} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Accounts.change_user(user))
     end)}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user(socket.assigns.user, user_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    save_user(socket, socket.assigns.action, user_params)
  end

  defp save_user(socket, :edit, user_params) do
    case Accounts.update_user(socket.assigns.user, user_params) do
      {:ok, user} ->
        notify_parent({:saved, user})

        {:noreply,
         socket
         |> put_flash(:info, "User updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_user(socket, :new, user_params) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        notify_parent({:saved, user})

        {:noreply,
         socket
         |> put_flash(:info, "User created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
