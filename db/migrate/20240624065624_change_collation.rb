class ChangeCollation < ActiveRecord::Migration[7.0]
  def change
    db_name = ActiveRecord::Base.connection_db_config.database
    tables = ActiveRecord::Base.connection.tables
    collation = 'utf8mb4_0900_ai_ci'
    reversible do |direction|
      direction.up do
        execute "ALTER DATABASE `#{db_name}` CHARACTER SET = utf8mb4 COLLATE = #{collation}"
        tables.each do |table|
          execute "ALTER TABLE `#{db_name}`.`#{table}` CONVERT TO CHARACTER SET utf8mb4 COLLATE #{collation}"
        end
      end
    end
  end
end
