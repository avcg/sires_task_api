defmodule SiresTaskApi.Notifier.Media.Email do
  @behaviour SiresTaskApi.Notifier.Media
  @config Application.get_env(:sires_task_api, __MODULE__)

  alias SiresTaskApi.{Notifier, Mailer, User}

  def notify(user, mod, txn) do
    email = build_email(user, mod, txn)
    Mailer.deliver_later(email)
  end

  defp build_email(user, mod, txn) do
    Gettext.with_locale(user.locale, fn ->
      bindings = [txn: txn, user: user]
      html_content = Notifier.render_template(mod, :html, bindings)

      Bamboo.Email.new_email(
        to: {User.full_name(user), user.email},
        from: @config[:from_email],
        subject: Notifier.render_template(mod, :subject, bindings),
        html_body: Notifier.render_layout("email.html.eex", html_content),
        text_body: Notifier.render_template(mod, :text, bindings)
      )
    end)
  end
end
