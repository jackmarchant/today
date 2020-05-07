defmodule Today.Repo.Migrations.AddUserTodos do
  use Ecto.Migration

  def change do
    alter table("todos") do
      add :user_id, references(:users), null: false
    end
  end
end
