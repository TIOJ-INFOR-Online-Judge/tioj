class ChangeCodeToBinary < ActiveRecord::Migration[7.0]
  def change
    create_table :code_contents do |t|
      t.binary :code, :limit => 4.gigabyte - 1
    end
    add_column :submissions, :code_length, :bigint, default: 0, null: false
    add_reference :submissions, :code_content

    reversible do |direction|
      direction.up do
        add_column :code_contents, :submission_id, :bigint
        execute %{
          INSERT INTO code_contents (submission_id, code)
          SELECT id, code FROM submissions
        }
        execute %{
          UPDATE submissions,
            (SELECT id, submission_id, LENGTH(code) AS length FROM code_contents) AS t
          SET submissions.code_content_id = t.id, submissions.code_length = t.length
          WHERE submissions.id = t.submission_id
        }
        remove_column :code_contents, :submission_id, :bigint
      end
      direction.down do
        execute %{
          UPDATE submissions,
            (SELECT submissions.id, code_contents.code FROM submissions, code_contents
             WHERE submissions.code_content_id = code_contents.id) AS t
          SET submissions.code = t.code
          WHERE submissions.id = t.id
        }
      end
    end

    remove_column :submissions, :code
    add_foreign_key :submissions, :code_contents
    change_column_null :submissions, :code_content_id, false
  end
end
