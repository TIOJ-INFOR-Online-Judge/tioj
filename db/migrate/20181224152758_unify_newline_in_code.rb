class UnifyNewlineInCode < ActiveRecord::Migration[4.2]
  def up
    Submission.update_all("code = REPLACE(REPLACE(code, '\r\n', '\n'), '\r', '\n')")
  end
end
