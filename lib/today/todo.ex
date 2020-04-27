defmodule Today.Todo do
    use Ecto.Schema
    import Ecto.Changeset

    schema "todos" do
        field :title, :string
        field :completed, :boolean, default: false

        timestamps()
    end

    def changeset(struct, params) do
        struct
        |> cast(params, [:title, :completed])
        |> validate_required([:title, :completed])
    end
end