defmodule LiveViewStudioWeb.VolunteersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Volunteers
  alias LiveViewStudio.Volunteers.Volunteer

  def mount(_params, _session, socket) do
    volunteers = Volunteers.list_volunteers()
    
    changeset = Volunteers.change_volunteer(%Volunteer{})
    
    form = to_form(changeset)
    
    socket =
      socket
      |> stream(:volunteers, volunteers)
      |> assign(:form, to_form(changeset))
    
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Volunteer Check-In</h1>
    <div id="volunteer-checkin">
      <.form for={@form} phx-submit="save" phx-change="validate">
        <.input field={@form[:name]} placeholder="Name" autocomplete="off" phx-debounce="2000"/>
        <.input field={@form[:phone]} type="tel" placeholder="Phone" phx-debounce="blur"/>
        <.button phx-disable-with="Saving...">
          Check In
        </.button>

      </.form>
      <div id="volunteers" phx-update="stream">
        <div
          :for={{volunteer_id, volunteer} <- @streams.volunteers}
          class={"volunteer #{if volunteer.checked_out, do: "out"}"}
          id={volunteer_id}
        >
        <div class="name">
          <%= volunteer.name %>
        </div>
        <div class="phone">
          <%= volunteer.phone %>
        </div>
        <div class="status">
          <button phx-click="toggle-status" phx-value-id={volunteer.id}>
            <%= if volunteer.checked_out, do: "Check In", else: "Check Out" %>
          </button>
          <.link class="delete" phx-click="delete-volunteer" phx-value-id={volunteer.id}>
            <.icon name="hero-trash-solid" />
          </.link>
        </div>
      </div>
      </div>
    </div>
    """
  end
  
  def handle_event("delete-volunteer", %{"id" => id}, socket) do
    volunteer = Volunteers.get_volunteer!(id)
    
    {:ok, _} = Volunteers.delete_volunteer(volunteer)
    
    socket = stream_delete(socket, :volunteers, volunteer)
    
    {:noreply, socket}
  end
  
  def handle_event("toggle-status", %{"id" => id}, socket) do
    volunteer = Volunteers.get_volunteer!(id)
    
    {:ok, volunteer} = 
      Volunteers.update_volunteer(
        volunteer, 
        %{checked_out: !volunteer.checked_out})
    
    socket = stream_insert(socket, :volunteers, volunteer)
    
    {:noreply, socket}
  end
  
  def handle_event("validate", %{"volunteer" => volunteer_params}, socket) do
    changeset = 
      %Volunteer{}
      |> Volunteers.change_volunteer(volunteer_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end
  
  def handle_event("save", %{"volunteer" => volunteer_params}, socket) do
    case Volunteers.create_volunteer(volunteer_params) do
      {:error, changeset} ->
        socket = put_flash(socket, :error, "Error, please fix!")
        {:noreply, assign(socket, :form, to_form(changeset))}
      {:ok, volunteer} -> 
        
        socket = put_flash(socket, :info, "Volunteer Added!")
        socket = 
          stream_insert(socket, :volunteers, volunteer, at: 0)
        
        changeset = Volunteers.change_volunteer(%Volunteer{})
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end
end
