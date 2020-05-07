defmodule Today do
  @moduledoc """
  Today keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  import Ecto.Query

  def get_todos(%Today.User{} = user) do
    Today.Todo
    |> where([t], t.user_id == ^user.id)
    |> order_by([t], desc: t.id)
    |> Today.Repo.all()
  end

  def create_todo(params) do
    %Today.Todo{}
    |> Today.Todo.changeset(params)
    |> Today.Repo.insert()
    |> broadcast(:todo_created)
  end

  def delete_todo(id) do
    Today.Todo
    |> Today.Repo.get!(id)
    |> Today.Repo.delete()
    |> broadcast(:todo_deleted)
  end

  def toggle_todo(id, completed) do
    {1, [todo]} =
      from(t in Today.Todo, where: t.id == ^id, select: t)
      |> Today.Repo.update_all(set: [completed: completed])
    
    broadcast({:ok, todo}, :todo_toggled)
  end

  def create_user(changeset) do
    changeset
    |> Today.Repo.insert()
    |> broadcast(:user_created)
  end

  def authenticate(%{email: email, password: password}) do
    Today.User
    |> Today.Repo.get_by(email: email)
    |> Comeonin.Bcrypt.check_pass(password, hash_key: :password)
  end

  def signup_or_login(params) do
    %{
      email: params["email"],
      password: params["password"]
    }
    |> authenticate()
    |> process_authentication(params)
  end

  def subscribe(channel) do
    Phoenix.PubSub.subscribe(Today.PubSub, channel)
  end

  defp broadcast({:error, _reason} = error, _event), do: error
  defp broadcast({:ok, %Today.Todo{} = todo}, event) do
    Phoenix.PubSub.broadcast(Today.PubSub, "todos", {event, todo})
    {:ok, todo}
  end
  defp broadcast({:ok, %Today.User{} = user}, event) do
    Phoenix.PubSub.broadcast(Today.PubSub, "users", {event, user})
    {:ok, user}
  end

  defp process_authentication({:error, _}, params) do
    %Today.User{}
    |> Today.User.changeset(params)
    |> create_user()
  end
  defp process_authentication(tuple, _), do: broadcast(tuple, :user_logged_in)
end
