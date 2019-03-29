class ResetOutputLimit < ActiveRecord::Migration
  def change
    Limit.update_all(output: 262144)
  end
end
