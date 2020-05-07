defmodule Today.User do
    use Ecto.Schema
    import Ecto.Changeset
    alias Comeonin.Bcrypt

    schema "users" do
        field :email, :string
        field :password, :string

        timestamps()
    end

    def changeset(struct, params) do
        struct
        |> cast(params, [:email, :password])
        |> unique_constraint(:email)
        |> validate_required([:email, :password])
        |> validate_length(:email, min: 2)
        |> validate_length(:password, min: 8)
        |> validate_format(:email, ~r/@/)
        |> update_change(:password, &Bcrypt.hashpwsalt/1)
    end
end