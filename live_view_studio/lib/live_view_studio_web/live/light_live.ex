defmodule LiveViewStudioWeb.LightLive do
  use LiveViewStudioWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, brightness: 10, temp: "3000")
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
      <h1>Front Porch Light</h1>
      <div id="light">
        <div class="meter">
          <span style={"width: #{@brightness}%; background: #{temp_color(@temp)}"}>
            <%= @brightness %>%
          </span>
        </div>
        <button phx-click="off">
          <img src="/images/light-off.svg">
        </button>
        <button phx-click="on">
          <img src="/images/light-on.svg">
        </button>
        <%!-- <button phx-click="up">
          <img src="/images/up.svg">
        </button>
        <button phx-click="down">
          <img src="/images/down.svg">
        </button> --%>
        <button phx-click="random">
          <img src="/images/fire.svg">
        </button>
        <form phx-change="change-brightness">
          <input type="range" min="0" max="100" phx-debounce="250"
          name="brightness" value={@brightness} />
        </form>
        <form phx-change="update-temp">
          <div class="temps">
            <%= for temp <- ["3000", "4000", "5000"] do %>
              <div>
                <input type="radio" id={temp} name="temp" value={temp} checked={temp == @temp}/>
                <label for={temp}><%= temp %></label>
              </div>
            <% end %>
          </div>
      </form>
      </div>
    """
  end
  
  def handle_event("update-temp", %{"temp" => temp}, socket) do
    socket = assign(socket, temp: temp)
    {:noreply, socket}
  end
  
  def handle_event("change-brightness", params, socket) do
    %{"brightness" => brightness } = params
    {:noreply, assign(socket, brightness: String.to_integer(brightness))}
  end

  def handle_event("off", _, socket) do
    {:noreply, assign(socket, brightness: 0)}
  end

  def handle_event("on", _, socket) do
    {:noreply, assign(socket, brightness: 100)}
  end

  def handle_event("up", _, socket) do
    # brightness = socket.assigns.brightness + 10
    # {:noreply, assign(socket, brightness: brightness)}

    socket = update(socket, :brightness, &min(&1 + 10, 100))
    {:noreply, socket}
  end

  def handle_event("down", _, socket) do
    # brightness = socket.assigns.brightness - 10
    # {:noreply, assign(socket, brightness: brightness)}
    socket = update(socket, :brightness, &max(&1 - 10, 0))
    {:noreply, socket}
  end

  def handle_event("random", _, socket) do
    brightness = 1..100 |> Enum.random()
    {:noreply, assign(socket, brightness: brightness)}
  end
  
  defp temp_color("3000"), do: "#F1C40D"
  defp temp_color("4000"), do: "#FEFF66"
  defp temp_color("5000"), do: "#99CCFF"
end
