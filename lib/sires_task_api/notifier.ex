defmodule SiresTaskApi.Notifier do
  require EEx
  use GenServer

  alias SiresTaskApi.{Repo, User.NotifierQuery}

  @media %{email: __MODULE__.Media.Email}
  @templates_base_path Path.join(~w(lib sires_task_api notifier templates))
  @formats ~w(subject html text)a
  @ext_map @formats |> Enum.map(&{".#{&1}", &1}) |> Map.new()

  # Compile email templates for operations.
  #
  # The convension is the following.
  # Given an operation module `SiresTaskApi.Foo.Bar.Create`.
  # - HTML template must be located at `lib/sires_task_api/notifier/templates/foo/bar/create.html.eex`
  # - Text template must be located at `lib/sires_task_api/notifier/templates/foo/bar/create.text.eex`
  # - Subject template must be located at `liv/sires_task_api/notifier/templates/foo/bar/create.subject.eex`
  # - Templates get operation's transaction struct under `@txn` binding.
  # - Subscriber's `SiresApiTask.User` struct is under `@user` binding.
  # - Templates get rendered in subscriber's current locale. Gettext should be used for i18n.
  # - If none one the templates is defined for the operation then emails no are being sent on it.
  @templates @templates_base_path
             |> Path.join("**/*.eex")
             |> Path.wildcard()
             |> Stream.map(fn path ->
               rel_path = path |> Path.relative_to(@templates_base_path)
               basename = rel_path |> Path.basename(".eex")
               ext = basename |> Path.extname()
               base_path = Path.join(Path.dirname(rel_path), Path.basename(basename, ext))
               {path, base_path}
             end)
             |> Enum.group_by(
               fn {_path, base_path} ->
                 Module.concat(SiresTaskApi, Macro.camelize(base_path))
               end,
               fn {path, base_path} ->
                 ext = path |> Path.basename(".eex") |> Path.extname()
                 key = @ext_map[ext]
                 unless key, do: raise("Unknown extension #{inspect(ext)} in #{inspect(path)}")

                 # Supress unused variables warnings.
                 source = "<% _ = txn; _ = user %>" <> File.read!(path)

                 fun = :"render_#{String.replace(base_path, "/", "_")}_#{key}"
                 EEx.function_from_string(:def, fun, source, [:txn, :user])
                 {key, fun}
               end
             )
             |> Enum.into(%{}, fn {mod, templates} ->
               templates = Map.new(templates)

               for format <- @formats do
                 unless templates[format], do: raise("Missing #{format} template for #{mod}")
               end

               {mod, templates}
             end)

  @available_operations for {op_mod, _} <- @templates, do: SiresTaskApi.Operation.dump(op_mod)
  def available_operations, do: @available_operations

  @available_media for {key, _} <- @media, do: to_string(key)
  def available_media, do: @available_media

  def start_link([]), do: GenServer.start_link(__MODULE__, nil)

  def init(state) do
    for {op_mod, _} <- @templates do
      operation = SiresTaskApi.Operation.dump(op_mod)
      SiresTaskApi.DomainPubSub |> Phoenix.PubSub.subscribe("operation:#{operation}")
    end

    {:ok, state}
  end

  def handle_info({:operation, op_mod, txn}, state) do
    notify(op_mod, txn)
    {:noreply, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  defp notify(op_mod, txn) do
    operation = SiresTaskApi.Operation.dump(op_mod)

    for {media_key, media_mod} <- @media do
      users = media_key |> to_string() |> subscribers(op_mod)

      for user <- users do
        if __MODULE__.Policy.Root.notify?(operation, user, txn) do
          apply(media_mod, :notify, [user, op_mod, txn])
        end
      end
    end
  end

  defp subscribers(media_key, op_mod) do
    operation = SiresTaskApi.Operation.dump(op_mod)
    NotifierQuery.call(%{media: media_key, operation: operation}) |> Repo.all()
  end

  def render_template(op_mod, key, txn: txn, user: user) do
    apply(__MODULE__, @templates[op_mod][key], [txn, user])
  end

  def gettext(msgid, bindings) do
    Gettext.dgettext(SiresTaskApi.Gettext, "notifier", msgid, bindings)
  end
end
