class ChangeCompilerText < ActiveRecord::Migration[4.2]
  def up
    Submission.where(compiler: 'c++').find_each do |sub|
      sub.update!(compiler: 'c++98')
    end
    Submission.where(compiler: 'c').find_each do |sub|
      sub.update!(compiler: 'c90')
    end
  end
end
