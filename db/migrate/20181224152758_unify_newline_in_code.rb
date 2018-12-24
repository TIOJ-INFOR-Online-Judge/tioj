class UnifyNewlineInCode < ActiveRecord::Migration
  def up
    Submission.update_all("code = REPLACE(REPLACE(code, '\r\n', '\n'), '\r', '\n')")
  end
end
