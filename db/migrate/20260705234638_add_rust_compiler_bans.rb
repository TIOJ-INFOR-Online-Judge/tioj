class AddRustCompilerBans < ActiveRecord::Migration[7.2]
  def change
    reversible do |dir|
      dir.up do
        python3 = Compiler.find_by(name: 'python3')
        haskell = Compiler.find_by(name: 'haskell')
        rust = Compiler.find_by(name: 'rust 2021')
        unless rust
          # Other properties will be filled in by CompilerHelper.generate_table
          rust = Compiler.create!(name: 'rust 2021')
        end

        problem_ids = BanCompiler.where(
          with_compiler_type: 'Problem',
          compiler_id: [python3.id, haskell.id]
        ).group(:with_compiler_id).having('COUNT(DISTINCT compiler_id) = 2').pluck(:with_compiler_id)
        next if problem_ids.empty?

        values = problem_ids.map do |problem_id|
          {compiler_id: rust.id, with_compiler_type: 'Problem', with_compiler_id: problem_id}
        end
        BanCompiler.import values, on_duplicate_key_ignore: true
      end

      dir.down do
        rust = Compiler.find_by(name: 'rust 2021')
        if rust
          BanCompiler.where(compiler_id: rust.id).delete_all
        end
      end
    end
  end
end
