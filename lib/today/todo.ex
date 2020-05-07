defmodule Today.Todo do
    use Ecto.Schema
    import Ecto.Changeset

    schema "todos" do
        field :title, :string
        field :completed, :boolean, default: false

        belongs_to :user, Today.User

        timestamps()
    end

    def changeset(struct, params) do
        struct
        |> cast(params, [:title, :completed])
        |> put_assoc(:user, params.user)
        |> validate_required([:title, :completed, :user])
    end
end