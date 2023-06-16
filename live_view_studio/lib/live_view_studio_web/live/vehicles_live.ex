defmodule LiveViewStudioWeb.VehiclesLive do
  use LiveViewStudioWeb, :live_view
  alias LiveViewStudio.Vehicles
  alias LiveViewStudioWeb.CustomComponents


  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        make: "",
        vehicles: [],
        loading: false,
        matches: []
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>🚙 Find a Vehicle 🚘</h1>
    <div id="vehicles">
      <form phx-submit="search" phx-change="suggest">
        <input
          type="text"
          name="query"
          value={@make}
          placeholder="Make or model"
          autofocus
          autocomplete="off"
          readonly={@loading}
          list="matches"
          phx-debounce="1000"
        />
        <button>
          <img src="/images/search.svg" />
        </button>
      </form>
      
      <datalist id="matches">
        <%= for match <- @matches do %>
        <option value={match}>
          <%= match %>
        </option>
        <% end %>
      </datalist>
      
      <CustomComponents.loading loading={@loading}/>

      <div class="vehicles">
        <ul>
          <li :for={vehicle <- @vehicles}>
            <span class="make-model">
              <%= vehicle.make_model %>
            </span>
            <span class="color">
              <%= vehicle.color %>
            </span>
            <span class={"status #{vehicle.status}"}>
              <%= vehicle.status %>
            </span>
          </li>
        </ul>
      </div>
    </div>
    """
  end
  
  def handle_event("search", %{"query" => make}, socket) do
    send(self(), {:run_search, make})
    
    socket = 
      assign(socket,
      make: make,
      vehicles: [],
      loading: true)
      
      {:noreply, socket}
  end
  
  def handle_event("suggest", %{"query" => prefix}, socket) do
    matches = Vehicles.suggest(prefix)
    {:noreply, assign(socket, matches: matches)}
  end
  
  
  def handle_info({:run_search, make}, socket) do
    socket = assign(socket,
    make: make,
    vehicles: Vehicles.search(make),
    loading: false
    )
    
    {:noreply, socket}
  end
end
