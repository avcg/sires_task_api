defmodule SiresTaskApi.Repo.Migrations.ChangeTaskMembersUniqueIndex do
  use Ecto.Migration

  def up do
    drop unique_index(:task_members, [:task_id, :user_id])

    execute """
    ALTER TABLE task_members
    DROP CONSTRAINT task_members_pkey
    """

    execute """
    ALTER TABLE task_members
    ADD CONSTRAINT task_members_pkey
    PRIMARY KEY (task_id, user_id, role)
    """
  end

  def down do
    execute """
    ALTER TABLE task_members
    DROP CONSTRAINT task_members_pkey
    """

    execute """
    ALTER TABLE task_members
    ADD CONSTRAINT task_members_pkey
    PRIMARY KEY (task_id, user_id)
    """

    create unique_index(:task_members, [:task_id, :user_id])
  end
end
