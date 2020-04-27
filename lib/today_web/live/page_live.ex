defmodule TodayWeb.PageLive do
  use TodayWeb, :live_view
  use Timex

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Today.subscribe()
    {:ok, assign(socket, get_assigns()), temporary_assigns: [todos: []]}
  end

  @impl true
  def handle_event("toggle-complete", params = %{"id" => todo_id}, socket) do
    value = Map.get(params, "value", "off")
    Today.toggle_todo(todo_id, value == "on")
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", _, socket) do
    Today.create_todo(%{title: socket.assigns.new_todo})
    {:noreply, update(socket, :new_todo, fn _ -> "" end)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    Today.delete_todo(id)
    {:noreply, socket}
  end

  @impl true
  def handle_event("change-todo", %{"new_todo" => %{"title" => title}}, socket) do
    {:noreply, assign(socket, new_todo: title)}
  end

  @impl true
  def handle_info({:todo_created, todo}, socket) do
    {:noreply, update(socket, :todos, fn todos -> [todo | todos] end)}
  end

  @impl true
  def handle_info({:todo_toggled, todo}, socket) do
    {:noreply, update(socket, :todos, fn todos -> [todo | todos] end)}
  end

  @impl true
  def handle_info({:todo_deleted, todo}, socket) do
    IO.inspect todo, label: "deleted todo"
    {:noreply, update(socket, :todos, fn todos -> [todo | todos] end)}
  end

  defp get_assigns() do
    [
      date: get_todays_date(),
      todos: Today.get_todos()
    ]
  end
  
  defp get_todays_date do
    "Australia/Sydney"
    |> Timex.now()
    |> Timex.format!("{WDshort} {D} {Mfull} {YYYY}")
  end
end
