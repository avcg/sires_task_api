defmodule SiresTaskApi.Repo.Migrations.AddFulltextIndices do
  use Ecto.Migration

  # https://dba.stackexchange.com/a/164081/34953
  def up do
    execute """
    CREATE OR REPLACE FUNCTION f_concat_ws(TEXT, VARIADIC TEXT[])
      RETURNS TEXT LANGUAGE sql IMMUTABLE AS 'SELECT ARRAY_TO_STRING($2, $1)'
    """

    execute """
    CREATE INDEX users_fulltext_index ON users USING GIN (
      TO_TSVECTOR('simple', REGEXP_REPLACE(email::TEXT, '[@\.\+_-]', ' ', 'g'))
    )
    """

    execute """
    CREATE INDEX tasks_fulltext_index ON tasks USING GIN (
      TO_TSVECTOR('simple', f_concat_ws(' ', name::TEXT, description::TEXT))
    )
    """
  end

  def down do
    execute("DROP INDEX tasks_fulltext_index")
    execute("DROP INDEX users_fulltext_index")
    execute("DROP FUNCTION f_concat_ws")
  end
end
