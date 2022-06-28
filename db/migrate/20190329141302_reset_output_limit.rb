class ResetOutputLimit < ActiveRecord::Migration[4.2]
  def change
    Limit.update_all(output: 262144)
  end
end
