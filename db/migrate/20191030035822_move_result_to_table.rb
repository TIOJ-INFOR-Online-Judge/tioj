class MoveResultToTable < ActiveRecord::Migration[4.2]
  def change
    arr = []
    Submission.all.each do |sub|
      tid = sub.id
      arr += sub._result.split("/").each_slice(3).map.with_index { |res, id|
        {:submission_id => tid, :position => id, :result => res[0],
         :time => res[1].to_i, :memory => res[2].to_i,
         :score => res[0] == 'AC' ? 100 : 0}
      }
      if arr.size >= 10000 then
        SubmissionTask.import(arr)
        arr = []
      end
    end
    SubmissionTask.import(arr)
    remove_column :submissions, :_result
  end
end
