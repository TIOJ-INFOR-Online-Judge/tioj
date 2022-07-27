class UseZeroBasedPositionOnTestdata < ActiveRecord::Migration[7.0]
  def up
    Testdatum.update_all("position = position - 1")
  end
end
