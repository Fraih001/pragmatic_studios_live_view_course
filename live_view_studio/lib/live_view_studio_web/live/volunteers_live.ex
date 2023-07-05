defmodule LiveViewStudioWeb.VolunteersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Volunteers
  alias LiveViewStudio.Volunteers.Volunteer

  def mount(_params, _session, socket) do
    volunteers = Volunteers.list_volunteers()
    
    changeset = Volunteers.change_volunteer(%Volunteer{})
    
    form = to_form(changeset)
    
    socket =
      assign(socket,
        volunteers: volunteers,
        form: form
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Volunteer Check-In</h1>
    <div id="volunteer-checkin">
      <.form for={@form} phx-submit="save" phx-change="validate">
        <.input field={@form[:name]} placeholder="Name" autocomplete="off"/>
        <.input field={@form[:phone]} type="tel" placeholder="Phone" />
        <.button phx-disable-with="Saving...">
          Check In
        </.button>

      </.form>
      <div
        :for={volunteer <- @volunteers}
        class={"volunteer #{if volunteer.checked_out, do: "out"}"}
      >
        <div class="name">
          <%= volunteer.name %>
        </div>
        <div class="phone">
          <%= volunteer.phone %>
        </div>
        <div class="status">
          <button>
            <%= if volunteer.checked_out, do: "Check In", else: "Check Out" %>
          </button>
        </div>
      </div>
    </div>
    """
  end
  
  def handle_event("validate", %{"volunteer" => volunteer_params}, socket) do
    {:noreply, socket}
  end
  
  def handle_event("save", %{"volunteer" => volunteer_params}, socket) do
    case Volunteers.create_volunteer(volunteer_params) do
      {:error, changeset} ->
        socket = put_flash(socket, :error, "Error, please fix!")
        {:noreply, assign(socket, :form, to_form(changeset))}
      {:ok, volunteer} -> 
        
        socket = put_flash(socket, :info, "Volunteer Added!")
        socket = 
          update(socket, 
          :volunteers,
          fn volunteers -> [volunteer | volunteers] end
        )
        
        changeset = Volunteers.change_volunteer(%Volunteer{})
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end
end
