class ChangeTimestampsToMicrosecondPrecision < ActiveRecord::Migration[7.0]
  def up
    table_columns do |table, column|
      change_column table, column, :datetime, limit: 6
    end
  end

  def down
    table_columns do |table, column|
      change_column table, column, :datetime
    end
  end

  private

  def table_columns
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.columns(table).each do |column|
        yield table, column.name if column.type == :datetime && block_given?
      end
    end
  end
end
