# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     SiresTaskApi.Repo.insert!(%SiresTaskApi.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

SiresTaskApi.Repo.insert!(%SiresTaskApi.User{
  email: "admin@example.com",
  password_hash: Comeonin.Bcrypt.hashpwsalt("12345"),
  role: "admin"
})
