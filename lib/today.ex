defmodule Today do
  @moduledoc """
  Today keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  import Ecto.Query

  def get_todos do
    Today.Repo.all(from t in Today.Todo, order_by: [desc: t.id])
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

  def subscribe do
    Phoenix.PubSub.subscribe(Today.PubSub, "todos")
  end

  defp broadcast({:error, _reason} = error, _event), do: error
  defp broadcast({:ok, todo}, event) do
    Phoenix.PubSub.broadcast(Today.PubSub, "todos", {event, todo})
    {:ok, todo}
  end
end
