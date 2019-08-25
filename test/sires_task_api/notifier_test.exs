defmodule SiresTaskApi.NotifierTest do
  use SiresTaskApi.DataCase
  use Bamboo.Test, shared: true

  test "email notification" do
    Task.start_link(fn -> SiresTaskApi.Notifier.start_link([]) end)

    user = insert!(:user, first_name: "Vasya", last_name: "Pupkin", email: "v.pupkin@example.com")
    insert!(:project_member, project: user.inbox_project, user: user, role: "admin")
    insert!(:notification_subscription, user: user, media: "email", operation: "Task.Create")

    params = %{task: %{project_id: user.inbox_project_id, name: "Test task"}}
    {:ok, _} = SiresTaskApi.Task.Create |> ExOperation.run(%{user: user}, params)

    assert_receive({:delivered_email, email}, 3000, "Email not received")
    assert email.to == [{"Vasya Pupkin", "v.pupkin@example.com"}]
    assert email.subject == ~s[New task \"Test task\" in project \"Inbox\"]
  end
end
