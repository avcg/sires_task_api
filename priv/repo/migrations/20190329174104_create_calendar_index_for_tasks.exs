defmodule SiresTaskApi.Repo.Migrations.CreateCalendarIndexForTasks do
  use Ecto.Migration

  def change do
    execute """
    CREATE INDEX tasks_calendar_index
    ON tasks (
      EXTRACT(YEAR FROM finish_time),
      EXTRACT(MONTH FROM finish_time)
    )
    """
  end

  def down do
    execute "DROP INDEX tasks_calendar_index"
  end
end
