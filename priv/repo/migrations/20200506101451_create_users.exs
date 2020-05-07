defmodule Today.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table("users") do
      add :email, :string, null: false, unique: true
      add :password, :string, null: false

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
