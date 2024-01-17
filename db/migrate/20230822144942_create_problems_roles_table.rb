class CreateProblemsRolesTable < ActiveRecord::Migration[7.0]
  def change
    create_table :problems_roles, id: false do |t|
      t.belongs_to :problem, index: true
      t.belongs_to :role, index: true

      t.timestamps
    end
  end
end
