defmodule SiresTaskApiWeb.PutLocale do
  def init(_opts), do: nil

  def call(conn, _opts) do
    locale = conn.assigns.current_user.locale

    if locale in Gettext.known_locales(SiresTaskApi.Gettext) do
      Gettext.put_locale(SiresTaskApi.Gettext, locale)
    end

    conn
  end
end
