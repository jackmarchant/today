defmodule Today.Repo.Migrations.AddTodos do
  use Ecto.Migration

  def change do
    create table("todos") do
      add :title, :string
      add :completed, :bool

      timestamps()
    end
  end
end
