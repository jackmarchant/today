defmodule TodayWeb.PageLive do
  use TodayWeb, :live_view
  use Timex

  alias Today.User

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do 
      Today.subscribe("users")
      Today.subscribe("todos")
    end
    {:ok, assign(socket, get_assigns())}
  end

  @impl true
  def handle_event("toggle-complete", params = %{"id" => todo_id}, socket) do
    value = Map.get(params, "value", "off")
    Today.toggle_todo(todo_id, value == "on")
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"user" => params}, socket) do
    {:noreply, assign(socket, :changeset, user_changeset(params))}
  end

  @impl true
  def handle_event("login_or_signup", %{"user" => params}, socket) do
    with {:ok, user} <- Today.signup_or_login(params) do
      {:noreply, assign(socket, :user, user)}
    else
      _ -> {:noreply, put_flash(socket, :error, "Sorry. That password doesn't look right. Please try again.")}
    end
  end

  @impl true
  def handle_event("save", _, socket) do
    Today.create_todo(%{title: socket.assigns.new_todo, user: socket.assigns.user})
    {:noreply, update(socket, :new_todo, fn _ -> "" end)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    {:ok, _} = Today.delete_todo(id)
    {:noreply, assign(socket, todos: Today.get_todos(socket.assigns.user))}
  end

  @impl true
  def handle_event("change-todo", %{"new_todo" => %{"title" => title}}, socket) do
    {:noreply, assign(socket, new_todo: title)}
  end

  @impl true
  def handle_info({_event, %Today.Todo{}}, socket) do
    {:noreply, assign(socket, todos: Today.get_todos(socket.assigns.user))}
  end

  @impl true
  def handle_info({_event, %Today.User{} = user}, socket) do
    {:noreply, assign(socket, %{user: user, signed_in: true, todos: Today.get_todos(user)})}
  end

  defp get_assigns() do
    [
      date: get_todays_date(),
      todos: [],
      user: nil,
      changeset: user_changeset(),
      signed_in: false
    ]
  end

  defp user_changeset(params \\ %{}) do
    User.changeset(%User{}, params)
  end
  
  defp get_todays_date do
    "Australia/Sydney"
    |> Timex.now()
    |> Timex.format!("{WDfull} {D} {Mfull} {YYYY}")
  end
end
