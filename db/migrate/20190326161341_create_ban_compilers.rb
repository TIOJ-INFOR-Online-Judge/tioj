class CreateBanCompilers < ActiveRecord::Migration[4.2]
  def up
    create_table :ban_compilers do |t|
      t.references :contest, foreign_key: true
      t.references :compiler, foreign_key: true
      t.index [:contest_id, :compiler_id], unique: true

      t.timestamps null: false
    end

    comps = Compiler.where(:name => ['python2', 'python3', 'haskell'])
    ActiveRecord::Base.transaction do
      Contest.all.each do |c|
        comps.each do |x|
          c.compilers << x
        end
      end
    end
  end
  def down
    drop_table :ban_compilers
  end
end
