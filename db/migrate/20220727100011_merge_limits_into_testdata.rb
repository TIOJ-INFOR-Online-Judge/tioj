class MergeLimitsIntoTestdata < ActiveRecord::Migration[7.0]
  def change
    add_column :testdata, :time_limit, :integer, default: 1000
    add_column :testdata, :vss_limit, :integer, default: 65536
    add_column :testdata, :rss_limit, :integer
    add_column :testdata, :output_limit, :integer, default: 65536
    execute %{
      UPDATE testdata LEFT JOIN limits ON limits.testdatum_id = testdata.id
      SET testdata.time_limit = limits.time,
          testdata.vss_limit = limits.vss,
          testdata.rss_limit = limits.rss,
          testdata.output_limit = limits.output
    }
    drop_table :limits
  end
end
