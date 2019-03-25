defmodule SiresTaskApi.Repo.Migrations.ChangeTaskReferencesPk do
  use Ecto.Migration

  def change do
    execute "ALTER TABLE task_references DROP CONSTRAINT task_references_pkey"

    drop unique_index(:task_references, [:parent_task_id, :child_task_id, :reference_type])

    execute "ALTER TABLE task_references DROP COLUMN id"

    execute """
    ALTER TABLE task_references
    ADD CONSTRAINT task_references_pkey
    PRIMARY KEY (parent_task_id, child_task_id)
    """
  end
end
