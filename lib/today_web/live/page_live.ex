defmodule TodayWeb.PageLive do
  use TodayWeb, :live_view
  use Timex

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, get_assigns())}
  end

  @impl true
  def handle_event("toggle-complete", params = %{"id" => todo_id}, socket) do
    value = Map.get(params, "value", "off")
    todos = Enum.map(socket.assigns.todos, &map_todo(&1, String.to_integer(todo_id), value == "on"))
    {:noreply, assign(socket, todos: todos)}
  end

  @impl true
  def handle_event("save", _, socket) do
    todos = socket.assigns.todos
    todo = create_todo(socket.assigns.new_todo, Enum.count(todos) + 1)
    {:noreply, assign(socket, todos: todos ++ [todo])}
  end

  @impl true
  def handle_event("change-todo", %{"new_todo" => %{"title" => title}}, socket) do
    {:noreply, assign(socket, new_todo: title)}
  end

  defp map_todo(todo = %{id: id}, id, completed)do
    Map.put(todo, :completed, completed)
  end
  defp map_todo(todo, _id, _) do
    todo
  end

  defp create_todo(title, id) do
    %{
      title: title,
      completed: false,
      id: id
    }
  end
  
  defp get_assigns() do
    [
      date: get_todays_date(),
      todos: get_todos()
    ]
  end
  
  defp get_todays_date do
    "Australia/Sydney"
    |> Timex.now()
    |> Timex.format!("{WDshort} {D} {Mfull} {YYYY}")
  end

  defp get_todos do
    [
      %{
        title: "UI tweaks",
        completed: true,
        id: 1,
      },
      %{
        title: "add analytics events",
        completed: false,
        id: 2,
      },
      %{
        title: "write tickets for mobile apps",
        completed: false,
        id: 3,
      }
    ]
  end
end
